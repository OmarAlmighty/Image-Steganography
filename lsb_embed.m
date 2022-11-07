function [ stego,len ] = lsb_embed( c,s_dec,k,ev )
%% Create encoding matrix
m = zeros(2^k);
for i=1:2^k
    m(i,ev(1,i)+1) = 1;
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
red = c(:,:,1); % get red channel of cover image
green = c(:,:,2); % get green channel of cover image
blue = c(:,:,3); % get blue channel of cover image

red_bin = dec2bin(red,8);
green_bin = dec2bin(green,8);
blue_bin = dec2bin(blue,8);
%%
rows = size(red_bin,1);
counter = 1;
for i=1:rows
    if counter > size(sm,2)-k
        break
    end
    red_bin(i,end-k+1:end) = sm(1,counter:counter+k-1);
    counter = counter +k;
    
    if counter > size(sm,2)-k
        break
    end
    green_bin(i,end-k+1:end) = sm(1,counter:counter+k-1);
    counter = counter +k;
    
    if counter > size(sm,2)-k
        break
    end
    blue_bin(i,end-k+1:end) = sm(1,counter:counter+k-1);
    counter = counter +k;
end

red_dec = mybin2dec(red_bin);
green_dec = mybin2dec(green_bin);
blue_dec = mybin2dec(blue_bin);
[w,h] = size(red);
red = reshape(red_dec,w,h);
green = reshape(green_dec,w,h);
blue = reshape(blue_dec,w,h);

stego(:,:,1) = red;
stego(:,:,2) = green;
stego(:,:,3) = blue;
end
function x = mybin2dec(s)
% Lean version of Matlab's BIN2DEC, see: help bin2dec
n     = size(s, 2);
v     = s - '0';
twos  = pow2(n-1:-1:0);
x     = v * twos.';
end

function [ bin ] = get_bin_string(str)
str = dec2bin(str);
j =1;
bin = char(zeros(1,size(str,1) * size(str,2)));
counter = size(str,2);
for i=1:size(str,1)
    bin(1,j:j+counter-1) = str(i,:);
    j = j+counter;
end
end
