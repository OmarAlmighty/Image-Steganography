function [ stego,len ] = lsb_embed_color( c,s_dec,k,iv )
%%
stego = c;
[rows,cols,chnls] = size(stego);
counter = 1;
flag = 0;
%% Create encoding matrix
m = zeros(2^k);
for i=1:2^k
    m(i,iv(1,i)+1) = 1;
end
sub_msg = [];

for i=1:size(s_dec,2) % begin encoding secret message with encoding matrix
    val = s_dec(1,i)+1; %the value of val can be 0 and there is no index 0, so we consider adding 1
    col = find(m(val,:)==1); 
    sub_msg =[sub_msg,col];
end
sub_msg = sub_msg-1;
sm = get_bin_string(sub_msg);
len = length(sm);
%%
for r=1:rows
    for c=1:cols
        red = stego(r,c,1); % get red channel of cover image
        green = stego(r,c,2); % get green channel of cover image
        blue = stego(r,c,3); % get blue channel of cover image
        %% Convert each channel into binary
        red = dec2bin(red,8);
        green = dec2bin(green,8);
        blue = dec2bin(blue,8);
        %% hide k bit in each channel
        red(1,end-k+1:end) = sm(1,counter:counter+k-1);
        counter = counter + k;
        stego(r,c,1) = mybin2dec(red);
        if double(counter) >= len - double(k)
            flag = 1;
            break;
        end
        
        green(1,end-k+1:end) = sm(1,counter:counter+k-1);
        counter = counter + k;
        stego(r,c,2) = mybin2dec(green);
        if double(counter) >= len - double(k)
            flag = 1;
            break;
        end
        
        blue(1,end-k+1:end) = sm(1,counter:counter+k-1);
        counter = counter + k;
        stego(r,c,3) = mybin2dec(blue);
        if double(counter) >= len - double(k)
            flag = 1;
            break;
        end
        
    end
    if flag ==1
        break;
    end
end
end
function x = mybin2dec(s)
% Lean version of Matlab's BIN2DEC, see: help bin2dec
n     = size(s, 2);
v     = s - '0'; 
twos  = pow2(n-1:-1:0);
x     = v * twos.';
end

