function d = dprime(H,FP)
%Function to calculate dprime given:
%H = hit rate
%F = false positive/alarm rate
%values should be entered as proportions

d = norminv(H) - norminv(FP);

end