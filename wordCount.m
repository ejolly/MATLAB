function [count, slow_speed, fast_speed] = wordCount(sentence)
% Takes as input as sentence and counts the number of words
% Just make sure that the spaces in the sentence are correct or the result
% will be wrong (e.g. 'The cat ran fast' vs 'Thecat ran fast')
% speeds are based on average reading rate of 3-4 words/s

count = length(regexp(sentence, ' ', 'split'));
slow = count/3;
slow_speed = [num2str(count/3) ' seconds'];
fast_speed = [num2str(count/4) ' seconds'];