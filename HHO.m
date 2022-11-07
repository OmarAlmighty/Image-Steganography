%% HERE I USED "sum" FUNCTION  TO SUM THE "Rabbit_Energy" variable BEACUSE IT HOLDS 3 PSNR VALUES AND THIS CAUSES A PROBLEM
function [Rabbit_Energy,Rabbit_Location,CNVG,keys,psc]=HHO(N,T,lb,ub,k,c,s_dec,iv)
f = waitbar(0,'start...');
disp('HHO is now tackling your problem')
dim = 2;
tic
% initialize the location and Energy of the rabbit
Rabbit_Location=zeros(1,dim);
Rabbit_Energy=-inf;

%Initialize the locations of Harris' hawks
X=initialization(N,dim,ub,lb);
CNVG=zeros(1,T);
keys={};
psc=[];
t=0; % Loop counter
progress = 0;
inc = 1/(N*T*3);
while t<T
    info = strcat('Iteration(',num2str(t),'): ');
    progress = progress+inc;
    for i=1:size(X,1)
        waitbar(progress,f,strcat(info,'first loop'));
        % Check boundries
        FU=(X(i,:)>ub);
        FL=(X(i,:)<lb);
        X(i,:)=(X(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;
        % fitness of locations
        %X = round(X);
        p =shuffle(iv,X(i,:),k);
        stego = lsb_embed(c,s_dec,k,p);
        fitness=mean(PSNR(c,stego));
        % Update the location of Rabbit
        if fitness>Rabbit_Energy
            Rabbit_Energy=fitness;
            Rabbit_Location=X(i,:);
            psc = [psc,Rabbit_Energy];
            keys = [keys,Rabbit_Location];
        end
        progress=progress+inc;
    end
    %Rabbit_Energy = round(Rabbit_Energy);
    progress=progress+inc;
    
    E1=2*(1-(t/T)); % factor to show the decreaing energy of rabbit
    % Update the location of Harris' hawks
    for i=1:size(X,1)
        progress=progress+inc;
        waitbar(progress,f,strcat(info,'inside second for loop...'));
        E0=2*rand()-1; %-1<E0<1
        Escaping_Energy=E1*(E0);  % escaping energy of rabbit
        
        if abs(Escaping_Energy)>=1
            %% Exploration:
            % Harris' hawks perch randomly based on 2 strategy:
            
            q=rand();
            rand_Hawk_index = floor(N*rand()+1);
            X_rand = X(rand_Hawk_index, :);
            if q<0.5
                % perch based on other family members
                X(i,:)=X_rand-rand()*abs(X_rand-2*rand()*X(i,:));
            elseif q>=0.5
                % perch on a random tall tree (random site inside group's home range)
                X(i,:)=(Rabbit_Location(1,:)-mean(X))-rand()*((ub-lb)*rand+lb);
            end
            
        elseif abs(Escaping_Energy)<1
            %% Exploitation:
            % Attacking the rabbit using 4 strategies regarding the behavior of the rabbit
            
            %% phase 1: surprise pounce (seven kills)
            % surprise pounce (seven kills): multiple, short rapid dives by different hawks
            
            r=rand(); % probablity of each event
            
            if r>=0.5 && abs(Escaping_Energy)<0.5 % Hard besiege
                X(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-round(X(i,:)));
            end
            
            if r>=0.5 && abs(Escaping_Energy)>=0.5  % Soft besiege
                Jump_strength=2*(1-rand()); % random jump strength of the rabbit
                X(i,:)=(Rabbit_Location-X(i,:))-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:));
            end
            
            %% phase 2: performing team rapid dives (leapfrog movements)
            if r<0.5 && abs(Escaping_Energy)>=0.5, % Soft besiege % rabbit try to escape by many zigzag deceptive motions
                
                Jump_strength=2*(1-rand());
                X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:));
                %X = round(X);
                p = shuffle(iv,X(i,:),k);
                %X1 = round(X1);
                p1 = shuffle(iv,X1,k);
                stego1 = lsb_embed(c,s_dec,k,p1);
                stego2 = lsb_embed(c,s_dec,k,p);
                if mean(PSNR(c,stego1))>mean(PSNR(c,stego2)) % improved move?
                    X(i,:)=X1;
                    psc = [psc,mean(PSNR(c,stego1))];
                    keys = [keys,X1];
                    
                else % hawks perform levy-based short rapid dives around the rabbit
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:))+rand(1,dim).*Levy(dim);
                    %X2=round(X2);
                    p = shuffle(iv,X(i,:),k);
                    p2 = shuffle(iv,X2,k);
                    stego1 = lsb_embed(c,s_dec,k,p2);
                    stego2 = lsb_embed(c,s_dec,k,p);
                    if (mean(PSNR(c,stego1))>mean(PSNR(c,stego2))), % improved move?
                        X(i,:)=X2;
                        psc = [psc,mean(PSNR(c,stego1))];
                        keys = [keys,X2];
                    end
                end
            end
            
            if r<0.5 && abs(Escaping_Energy)<0.5, % Hard besiege % rabbit try to escape by many zigzag deceptive motions
                % hawks try to decrease their average location with the rabbit
                Jump_strength=2*(1-rand());
                X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X));
                %X1=round(X1);
                p = shuffle(iv,X(i,:),k);
                p1 = shuffle(iv,X1,k);
                stego1 = lsb_embed(c,s_dec,k,p1);
                stego2 = lsb_embed(c,s_dec,k,p);
                if mean(PSNR(c,stego1))>mean(PSNR(c,stego2)) % improved move?
                    X(i,:)=X1;
                    psc = [psc,mean(PSNR(c,stego1))];
                    keys = [keys,X1];
                else % Perform levy-based short rapid dives around the rabbit
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X))+rand(1,dim).*Levy(dim);
                    %X2= round(X2);
                    p = shuffle(iv,X(i,:),k);
                    p2 = shuffle(iv,X2,k);
                    stego1 = lsb_embed(c,s_dec,k,p2);
                    stego2 = lsb_embed(c,s_dec,k,p);
                    if (mean(PSNR(c,stego1))>mean(PSNR(c,stego2))), % improved move?
                        X(i,:)=X2;
                        psc = [psc,mean(PSNR(c,stego1))];
                        keys = [keys,X2];
                    end
                end
            end
            %%
        end
    end
    progress = progress+inc;
    t=t+1;
    CNVG(t)=sum(Rabbit_Energy); 
%   Print the progress every 1 iteration
   if mod(t,1)==0
       display(['At iteration ', num2str(t), ' the best fitness is ', num2str(Rabbit_Energy)]);
   end

end
toc
waitbar(1,f,'Done...');
end

% ___________________________________
function o=Levy(d)
beta=1.5;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
u=randn(1,d)*sigma;v=randn(1,d);step=u./abs(v).^(1/beta);
o=step;
end
% function [ p ] = shuffle( iv,key,k )
% p1 = iv(1,1:2^k);
% n = numel(p1);
% r1 = log(key(1,1))/10;
% r2 = key(1,2);
% for i = 1:n      % Knuth shuffle in forward direction: 1:n
%    w    = mod(ceil(r1 * r2 * i),n);
%    t    = p1(w+1);
%    p1(w+1) = p1(i);
%    p1(i) = t;
% end
% p2 = iv(1,2^k +1:end);
% n = numel(p2);
% for i = 1:n      % Knuth shuffle in forward direction: 1:n
%    w    = mod(ceil(r1 * r2 * i),n);
%    t    = p2(w+1);
%    p2(w+1) = p2(i);
%    p2(i) = t;
% end
% p = [p1,p2];
% 
% end
function [ p ] = shuffle( iv,key,k)
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

end
% Main paper:
% Harris hawks optimization: Algorithm and applications
% Ali Asghar Heidari, Seyedali Mirjalili, Hossam Faris, Ibrahim Aljarah, Majdi Mafarja, Huiling Chen
% Future Generation Computer Systems, 
% DOI: https://doi.org/10.1016/j.future.2019.02.028
% _____________________________________________________

function [X]=initialization(N,dim,up,down)

if size(up,1)==1
    X=rand(N,dim).*(up-down)+down;
end
if size(up,1)>1
    for i=1:dim
        high=up(i);low=down(i);
        X(:,i)=rand(1,N).*(high-low)+low;
    end
end
end
