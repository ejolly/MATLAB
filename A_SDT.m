function [A, b] = A_SDT(H,F)
%Function to calculate A (alternative to A prime, which is an alternative to dprime) given:
%H = hit rate
%F = false positive/alarm rate
%values should be entered as proportions
%Is a non-parametric alternative to d-prime particularly useful when hits
%or false alarms are equal to 0 or 1; formulae taken from:
% Zhang & Mueller, 2005

if (F <= .5) && (.5 <= H)
    A = .75 + ((H-F)/4) - (F*(1-H));
elseif (F <= H) && (H < .5)
    A = .75 + ((H-F)/4) - (F/(4*H));
elseif (0.5 < F) && (F <= H)
    A = .75 + ((H-F)/4) - ((1-H)/(4*(1-F)));
end

if (F<=.5) && (.5 <= H)
    b = (5-(4*H))/(1+(4*F));
elseif (F<H) && (H<.5)
    b = ((H^2)+H)/((H^2)+F);
elseif (.5<F) && (F<H)
    b = ((1-(F^2))+(1-H))/((1-(F^2))+(1-F));
    
    

end