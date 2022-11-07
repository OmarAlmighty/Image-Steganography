function [ p ] = shuffle( iv,key)
p = iv;
n = numel(p);
r1 = key(1,1)/500;
r2 = key(1,2);
for i = 1:n      % Knuth shuffle in forward direction: 1:n
   w    = mod(ceil(r1 * r2 * i),n);
   t    = p(w+1);
   p(w+1) = p(i);
   p(i) = t;

end