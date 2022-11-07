function [ split ] = split_bin( bin,k )
bin = reshape(bin',1,size(bin,1)*size(bin,2));
while mod(size(bin,2),k) ~= 0
    bin = ['0',bin];
end
split = cellstr(reshape(bin,k,[])');
split = cellstr(split)';
end

