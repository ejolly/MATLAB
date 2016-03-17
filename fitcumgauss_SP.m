function SSE = fitcumgauss_SP(guess,x, y)
        mu = guess(1);
        sigma = guess(2);
       
Est = 1/(sqrt(2*pi*sigma^2)) * exp(-( ((x-mu).^2) ./ (2*(sigma^2))));
Est = cumsum(Est) ./ sum(Est);
SSE = nansum( (y - Est).^2 ); 

save SP_xy x Est 