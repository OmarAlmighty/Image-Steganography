function [ img_res,bin_res ] = lsb_extract_color( stego,k,iv,len,s_dim )
%%
bin_res = [];
%%
[rows,cols,chnls] = size(stego);
flag = 0;
sub_msg = [];
for r=1:rows
    for c=1:cols
        red = dec2bin(stego(r,c,1),8);
        green = dec2bin(stego(r,c,2),8);
        blue = dec2bin(stego(r,c,3),8);
        %%
        sub_msg = [sub_msg, red(1,end-k+1:end)];
        sub_msg = [sub_msg, green(1,end-k+1:end)];
        sub_msg = [sub_msg, blue(1,end-k+1:end)];
        %%
        if size(sub_msg,2) > len
            flag =1;
            break;
        end
    end
    if flag ==1
        break;
    end
end
if size(sub_msg,2) > len
    sub_msg = sub_msg(1,1:len);%The extracted message
end

sub_msg_split = split_bin(sub_msg,k);

sub_msg = bin2dec(sub_msg_split)';

m = zeros(2^k);
%%
for i=1:2^k
    m(i,iv(1,i)+1) = 1;
end
%%
res = [];
for i=1:size(sub_msg,2)
    val = sub_msg(1,i)+1; %the value of val can be 0 and there is no index 0, so we consider adding 1
    row = find(m(:,val)==1)-1; 
    res =[res,row];
end
res_bin = get_bin_string(res);
if res_bin(1,1) =='0'
    %res_bin = res_bin(1,2:end); %toggling it affects the result image
end
if s_dim == 128
    %% Each channel is of size 128 * 128 * 8 bits, so red is from 1 to 131072, green from 131073 to 262144, and blue from 262145 to 393216
    red_bin = res_bin(1,1:131072);
    green_bin = res_bin(1,131073:262144);
    blue_bin = res_bin(1, 262145:end);
    img_res =uint8(zeros(128,128,3)); % the size of the secret image
elseif s_dim == 256
    %% FOR 256*256*8 img, red: [1:524288], green: [524289:1048576], blue: [1048577:1572864]
    red_bin = res_bin(1,1:524288);
    green_bin = res_bin(1,524289:1048576);
    blue_bin = res_bin(1, 1048577:end);
    img_res =uint8(zeros(256,256,3)); % the size of the secret image
end
%% Get red
counter = 1;
fl = 0;
for i=1:s_dim
    for j=1:s_dim
        if counter >size(red_bin,2)-7
            diff = counter - size(red_bin,2);
            img_res(i,j,1)=bin2dec(red_bin(1,counter-diff:end));
            fl = 1;
            break
        else
            img_res(i,j,1) = bin2dec(red_bin(1,counter:counter+7));
            counter = counter +8;
        end
    end
    if fl ==1
        break
    end
end
%% Get green
counter = 1;
fl = 0;
for i=1:s_dim
    for j=1:s_dim
        if counter >size(green_bin,2)-7
            diff = counter - size(green_bin,2);
            img_res(i,j,2)=bin2dec(green_bin(1,counter-diff:end));
            fl = 1;
            break
        else
            img_res(i,j,2) = bin2dec(green_bin(1,counter:counter+7));
            counter = counter +8;
        end
    end
    if fl ==1
        break
    end
end
%% Get blue
counter = 1;
fl = 0;
for i=1:s_dim
    for j=1:s_dim
        if counter >size(blue_bin,2)-7
            diff = counter - size(blue_bin,2);
            img_res(i,j,3)=bin2dec(blue_bin(1,counter-diff:end));
            fl = 1;
            break
        else
            img_res(i,j,3) = bin2dec(blue_bin(1,counter:counter+7));
            counter = counter +8;
        end
    end
    if fl ==1
        break
    end
end
img_res(:,:,1) = img_res(:,:,1)';
img_res(:,:,2) = img_res(:,:,2)';
img_res(:,:,3) = img_res(:,:,3)';
end

