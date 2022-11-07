N = 15;
T = 5;
lb = 1;
ub = 2000;
counter = 4;
for i =2:6
    for k =2:4
        secret_name = ['imgs/src/s',num2str(i),'.bmp'];
        cover_name = ['imgs/cover and stego 512/c',num2str(i),'.bmp'];
        stego_name = ['imgs/cover and stego 512/stego',num2str(counter),'.bmp'];
        fprintf('%s%s%s%s%s\n',cover_name,' + ',secret_name,' = ',stego_name);
        
        s = imread(secret_name);
        s_bin = dec2bin(s,8);
        s_bin = split_bin(s_bin,k);
        s_dec = bin2dec(s_bin)';
        c = imread(cover_name);
        
        ev = 0:2^k-1;
        ev = uint8(ev);
        ev = ev(randperm(length(ev)));
        [e,x,convg,keys,psc] = HHO(N,T,lb,ub,k,c,s_dec,ev);
        ev = shuffle(ev,x);
        [sprintf('%d,', ev(1:end-1)), sprintf('%d', ev(end))]
        [stego,len] = lsb_embed(c,s_dec,k,ev);
        stego = uint8(stego);
        
%         psnr_red = PSNR(c(:,:,1),stego(:,:,1));
%         psnr_green = PSNR(c(:,:,2),stego(:,:,2));
%         psnr_blue = PSNR(c(:,:,3),stego(:,:,3));
%         fprintf('PSNR: %f\t%f\t%f\n',psnr_red,psnr_green,psnr_blue);
%         
%         ssim_red = getMSSIM(c(:,:,1),stego(:,:,1));
%         ssim_green = getMSSIM(c(:,:,2),stego(:,:,2));
%         ssim_blue = getMSSIM(c(:,:,3),stego(:,:,3));
%         fprintf('SSIM: %f\t%f\t%f\n',ssim_red,ssim_green,ssim_blue);
%         
%         qi_red = qi(c(:,:,1),stego(:,:,1));
%         qi_green = qi(c(:,:,2),stego(:,:,2));
%         qi_blue = qi(c(:,:,3),stego(:,:,3));
%         fprintf('QI: %f\t%f\t%f\n',qi_red,qi_green,qi_blue);
%         
        imwrite(stego,stego_name,'bmp');
        counter = counter + 1;
        fprintf('\t%s\n','---DONE---');
    end
end
%[res,sm2] = dwt_extract(stego, 5, ev, len);

