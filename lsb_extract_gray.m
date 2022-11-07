function [ img_res,bin_res ] = lsb_extract_gray( stego,k,iv,len,s_dim )
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
%%
counter = 1;
img_res =uint8(zeros(s_dim,s_dim)); % the size of the secret image
fl = 0;
for i=1:s_dim
    for j=1:s_dim
        if counter >size(res_bin,2)-7
            diff = counter - size(res_bin,2);
            img_res(i,j)=bin2dec(res_bin(1,counter-diff:end));
            fl = 1;
            break
        else
            img_res(i,j) = bin2dec(res_bin(1,counter:counter+7));
            counter = counter +8;
        end
    end
    if fl ==1
        break
    end
end
img_res = img_res';
end

