function [ secret,secret_bin ] = lsb_extract( stego,k,ev,len )
%%
%% STEP 1: GET ENCODING MATRIX
m = zeros(2^k);
for i=1:2^k
    m(i,ev(1,i)+1) = 1;
end

%% STEP 2: APPLY DWT FOR EACH CHANNEL OF STEGO IMAGE
red = stego(:,:,1);
green = stego(:,:,2);
blue = stego(:,:,3);

%% STEP 3: CONVERT EACH SUB-BAND TO BINARY ROW VECTOR TO EASE EXTRACTION PROCESS
red_bin = dec2bin(abs(red),8);
green_bin = dec2bin(abs(green),8);
blue_bin = dec2bin(abs(blue),8);

%% STEP 4: EXTRACT
secret_bin = [];
counter = 1;
i = 1;
while counter < len-k
    secret_bin = [secret_bin, red_bin(i,end-k+1:end)];
    counter = counter + k;
    
    secret_bin = [secret_bin, green_bin(i,end-k+1:end)];
    counter = counter + k;
    
    secret_bin = [secret_bin, blue_bin(i,end-k+1:end)];
    counter = counter + k;
    i = i + 1;
end
secret_bin = secret_bin(1,1:len);

%% STEP 5: DECODE THE ENCODED BITS
secret_bin_split = split_bin(secret_bin,k);
sub_msg = bin2dec(secret_bin_split)';

m = zeros(2^k);
for i=1:2^k
    m(i,ev(1,i)+1) = 1;
end

res = [];
for i=1:size(sub_msg,2)
    val = sub_msg(1,i)+1; %the value of val can be 0 and there is no index 0, so we consider adding 1
    row = find(m(:,val)==1)-1; 
    res =[res,row];
end
res_bin = get_bin_string(res);

%% STEP 6: RECOVER THE IMAGE
counter = 1;
img_res1 =uint8(zeros(256,256)); % the size of the secret image
for i=1:256
    for j=1:256
        img_res1(i,j) = bin2dec(res_bin(1,counter:counter+7));
        counter = counter +8;
    end
end

img_res2 =uint8(zeros(256,256)); % the size of the secret image
for i=1:256
    for j=1:256
        img_res2(i,j) = bin2dec(res_bin(1,counter:counter+7));
        counter = counter +8;
    end
end


img_res3 =uint8(zeros(256,256)); % the size of the secret image
for i=1:256
    for j=1:256
        img_res3(i,j) = bin2dec(res_bin(1,counter:counter+7));
        counter = counter +8;
    end
end
secret(:,:,1) = img_res1(:,:)';
secret(:,:,2) = img_res2(:,:)';
secret(:,:,3) = img_res3(:,:)';
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
