function [sx,sy] = getTextCenter(windowPtr,tstring,x,y,twrap)
%
% [sx sy] = getTextCenter(onScreen,textStr,x,y,twrap)
%
% This function returns x and y values that are inputs for
% DrawFormattedText to center text on a point properly. 
% DrawFormmatedText will default to treating a desired x,y location as the 
% top left corner the desired text to be drawn, unless that location is
% the keyword argument 'center.' This function calculates the necessary
% offeet to properly center text on an x,y location. 
% 
% Inputs:
% windowPtr = screen you're planning to draw to
% tstring = the desired text string. If \n are included for line breaks the function will
% figure out x coordinate offset based on the longest sentence. 
% x,y, = the x and y position to center the text on

% Optional:
% twrap = amount of text wrapping to be performed; if provided this MUST be
% provided to DrawFormattedText as well

% Outputs:
% sx,sy = new coords when DrawFormattedText should start drawing from
%
% WARNING: sy calculation if vSpacing is included as an argument to DrawFormatted text,
% has not yet been implemented
%
%
% Authored -EJ 11/1/2011
% Updated to handle line breaks -EJ 2/25/15

if nargin ~= 5
    twrap = [];
end

%See if there are new line characters
newlinepos = strfind(char(tstring), '\n');

%If there are, break the string into a cell array
if ~isempty(newlinepos)
    cstring = cell(length(newlinepos)+1,1);
    cidx = 1;

    for sent = 1:size(cstring,1)
        if sent == size(cstring,1)
            cstring{sent,1} = tstring(cidx:end);
        else
        cstring{sent,1} = tstring(cidx:newlinepos(sent)-1);
        cidx = cidx + length(cstring{sent})+2;
        end
    end

    %Find the longest sentence  
    cstringLens = cellfun(@length, cstring);
    maxidx = find(cstringLens==max(cstringLens),1,'first');
        
    %Deal with text wrapping
    if ~isempty(twrap)
        
        extraSents = 0;
        for lencheck = 1:size(cstring,1)
            %If a sentence is > wrapping, shave it down and add to the extra line
            %counter
            if length(cstring{lencheck}) > twrap
                cstring{lencheck} = cstring{lencheck}(1:twrap);
                extraSents = extraSents + 2;
            else
            %Otherwise just add 1 extra line for that sentence
                extraSents = extraSents + 1;
            end
        end
    else
        %If no text wrapping simply count up the sentences 
        extraSents = size(cstring,1);
    end
    %String to measure bounds of 
    tstring = cstring{maxidx};

%Otherwise treat this as a single sentence
else
    %Check if Drawformatted text is going to wrap this text though and account for the
    %number of times that will happen
    if ~isempty(twrap)
        if length(tstring) > twrap
            extraSents = ceil(length(tstring)/twrap);
            tstring = tstring(1:twrap);
        end  
    else
        extraSents = 1;
    end
end
   
[normBoundsRect] = Screen('TextBounds', windowPtr,tstring);

w = normBoundsRect(3); 
h = normBoundsRect(4) * extraSents;

sx = x-(w/2); %starting x position
sy = y-(h/2); %starting y position


