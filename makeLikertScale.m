function scaleCoords = makeLikertScale(windowPtr,W,H,text,anchors,x,y, varargin)
%         [scaleCoords] = makeLikertScale(windowPtr, text, anchors, x, y, hspace, vspace)
%
%          This function helps deal with the suffering of perfectly aligning a Likert
%          scale on screen, along with providing information that can be supplied to
%          other functions such as Screen('FrameRect'...) to creating highlighted feedback
%          for responses made.
%
%          windowPtr = on screen window pointer
%          W = width of the screen
%          H = height of the screen
%          text = scale values separated by spaces
%          anchors = 1x2 cell array of anchor labels
%          x = horz value to center the scale at
%          y = vert value to center the scale at
%
%          Optional args:
%          hspace = spacing between scale values, defaults to W/20
%          vspace = spacing between anchor labels defaults to H/24; if this value is
%           negative will draw the anchor below the scale
%          s = 1x2 numerical array of scaling factor applied to the bounding rect of each
%           value of the scale. Particularly useful if this rect is passed to
%          Screen('FrameRect'...) in order to highlight the response chosen. Change this
%           value can help adjust the size of this highlighting frame.
%           Defaults to W/200, H/200
%
%          scaleCoords = cell array where:
%          first column = text to be draw
%          second column = x,y coords to draw that text
%          third column = bounding rect for that text at that location
%          Left and Right anchords are the last two rows in this array, respectively

%          scaleCoords = makeLikertScale(onScreen,W, H,'1 2 3 4 5',...
%              {'Not at all' 'Very much'}, x, y, W/20, H/24, [W/200 H/200])

%          Just pass this cell array to DrawFormattedText and voila! perfect likert scale
%          for i = 1:size(scaleCoords,1)
%               DrawFormattedText(windowPtr,scaleCoords{i,1}, scaleCoords{i,2}(1),...
%                   scaleCoords{i,2}(2), color)
%          end
%
%          And pass the third column to FrameRect for a perfect highlighted response
%          Screen('FrameRect', windowPtr, color, scaleCoords{response,3});
%
%          Authored EJ 2/18/15

optargs = {W/20 H/24 [W/300 H/300]}; 
numargs = length(varargin);
optargs(1:numargs) = varargin;
[hspace, vspace, s] = optargs{:};

%Split scale into individual steps and grab middle value
text = strsplit(text);
midEl = text{ceil(length(text)/2)};

%Find x,y coords to center middle value on the desired point
[midx,midy] = getTextCenter(windowPtr,midEl,x,y);


for i = 1:length(text)
    
    %Calculate a horizontal offset based on the distance of a particular scale value from
    %the mid-point of the scale
    hoffset = hspace * (i-str2double(midEl));
    
    %Figure out the coordinates to draw that value centered on the offset position
    [cx, cy] = getTextCenter(windowPtr,text{i},midx + hoffset, midy);
    
    %Figure out the bounding box 
    [~,valbounds] = Screen('TextBounds',windowPtr,num2str(i),cx,cy);
 
    scaleCoords{i,1} = text{i};
    scaleCoords{i,2} = [cx cy];
    scaleCoords{i,3} = valbounds + [-s(1) -s(2) s(1) s(2)];
    
    if i == 1 
        %Center left anchor based on lowest value in scale
        [Lx, Ly] = getTextCenter(windowPtr,anchors{1},midx+hoffset,midy-vspace);
        [~,Lbounds] = Screen('TextBounds',windowPtr, anchors{1}, Lx,Ly);
    elseif i == length(text)
        %Center right anchor based on highest value in scale
        [Rx, Ry] = getTextCenter(windowPtr,anchors{2},midx+hoffset,midy-vspace);
        [~,Rbounds] = Screen('TextBounds',windowPtr, anchors{1}, Lx,Ly);
    end

end
%Save anchor coords
scaleCoords{i+1,1} = anchors{1};
scaleCoords{i+1,2} = [Lx Ly];
scaleCoords{i+1,3} = Lbounds + [-s(1) -s(2) s(1) s(2)];
scaleCoords{i+2,1} = anchors{2};
scaleCoords{i+2,2} = [Rx Ry];
scaleCoords{i+2,3} = Rbounds + [-s(1) -s(2) s(1) s(2)];


