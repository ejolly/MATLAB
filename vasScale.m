classdef vasScale
% vasScale = class for creating a visual analog scale
%     
% This is an object that contains properties for drawing a visual analog scale in a
% desired PTB window. 
%
% Required inputs:
% windowPtr         = screen for drawing to
% W                 = screen width
% H                 = screen height
% x                 = x coordinate to center the scale on
% y                 = y coordinate to center the scale on
%
% Optional inputs, entered as 'key', value pairs:
% anchors           = 1x2 cell array of anchor text, e.g. {'Not at all' 'Very Much'}
% anchorColor       = 3x1 rgb vector of color for the anchor labels; default = match
%                     the scale color
% cursorColor       = 3x1 rgb vector of colors for the selection cursor; default = white
% scaleColor        = 3x1 rgb vector of colors for the scale; default = bright grey
% scaleLength       = a value between 0 and 1 for what fraction of horizontal screen
%                     size the scale should take up; default = .3, i.e. 30%
% scalecapLength    = a scale for the size of the end caps of the vas; default = H/24
% scaleThickness    = scalar value for pen width of scale drawing; default = 4
% cursorWidth       = scale value for pen width of cursor drawing, default = 6
% vSpacing          = spacing between anchors (if provided) and the scale; negative value
%                     will make anchors below the scale; default is H/24
% anchorSize        = text size of the anchors to display on the vas; default to text size
%                     of window in which vas is displayed  
%                     
%
% Methods:
%
% updatePos         = updates drawing position of scale given new x,y coordinates
% updateAnchors     = adds, removes or changes color of anchors of an existing vas
% getRating         = collects a rating using a mouse click
% showRating        = shows a rating, with options to add noise, change display color
% addGlassBound     = adds an invisible max that the cursor can't move past
% removeGlassBound  = removes an 'glass bounds' on a vas object 
%
%
% Usage:
%
% Initialize a vas object first using scale_var = vasScale(windowPtr,W,H,x,y....
% Then call methods on this object, e.g.:
% [rating buttons] = scale_var.getRating;
% scale_var = scale_var.updatePos;
%
% Additional help is available under each method

%TODO
    properties
        windowPtr = [];
        scale = [];
        cursor = [];
        anchors = {};
    end
    
    methods
        function obj = vasScale(windowPtr,W,H,x,y,varargin)
            class constructor
            
            %Parse input
            ip = inputParser;
            ip.CaseSensitive = false;
            ip.addRequired('windowPtr',@isnumeric);
            ip.addRequired('W',@isnumeric);
            ip.addRequired('H',@isnumeric);
            ip.addRequired('x',@isnumeric);
            ip.addRequired('y',@isnumeric);
            ip.addOptional('anchors', {''},@iscell);
            ip.addOptional('cursorColor', repmat(255,3,1), @isnumeric);
            ip.addOptional('scaleColor', repmat(211,3,1), @isnumeric);
            ip.addOptional('scaleLength', 0.3, @isnumeric);
            ip.addOptional('scalecapLength',-1,@isnumeric);
            ip.addOptional('scaleThickness', 4, @isnumeric);
            ip.addOptional('cursorWidth', 6, @isnumeric);
            ip.addOptional('vSpacing',[], @isnumeric);
            ip.addOptional('anchorColor',[], @isnumeric);
            ip.addOptional('anchorSize',[], @isnumeric);
            
            ip.parse(windowPtr,W,H,x,y,varargin{:});
            
            obj.windowPtr = ip.Results.windowPtr;
            W = ip.Results.W;
            H = ip.Results.H;
            x = ip.Results.x;
            y = ip.Results.y;
            Ccolor = ip.Results.cursorColor;
            Scolor = ip.Results.scaleColor;
            len = ip.Results.scaleLength;
            obj.scale.width = ip.Results.scaleThickness;
            obj.cursor.width = ip.Results.cursorWidth;
            obj.anchors.text = ip.Results.anchors;
            obj.cursor.hasGlassBound = 0;
            
            %Scale cap length is based on screen height
            if ip.Results.scalecapLength < 0
                obj.scale.cap.length = H/24;
            else
                obj.scale.cap.length = ip.Results.scalecapLength;
            end
            %Vertical spacing is dependent on screen height
            if isempty(ip.Results.vSpacing)
                obj.anchors.vspace = H/24;
            else
                obj.anchors.vspace = ip.Results.vSpacing;
            end
            
            %Ignore prepping textboxes if no anchors are provided
            if length(obj.anchors.text) > 1
                show_anchor = 1;
            else
                show_anchor = 0;
            end
            
            %Scale attributes
            obj.scale.main.length = W*len;
            obj.scale.main.start = [x-obj.scale.main.length/2; y];
            obj.scale.main.end = [x+obj.scale.main.length/2; y];
            obj.scale.main.midpoint = [x y];
            obj.scale.cap.startL = [obj.scale.main.start(1); y-obj.scale.cap.length/2];
            obj.scale.cap.endL = [obj.scale.main.start(1); y+obj.scale.cap.length/2];
            obj.scale.cap.startR = [obj.scale.main.end(1); y-obj.scale.cap.length/2];
            obj.scale.cap.endR = [obj.scale.main.end(1); y+obj.scale.cap.length/2];
            obj.scale.colors = [Scolor Scolor Scolor Scolor Scolor Scolor];
            
            %Cursor attributes
            obj.cursor.xmin = obj.scale.main.start(1);
            obj.cursor.xmax = obj.scale.main.end(1);
            obj.cursor.length = obj.scale.cap.length;
            obj.cursor.start = [x; obj.scale.cap.startL(2)];
            obj.cursor.end = [x; obj.scale.cap.endL(2)];
            obj.cursor.color = [Ccolor Ccolor];
            
            %Anchor attributes
            if show_anchor
                %Set default anchor size if not provided
                if isempty(ip.Results.anchorSize)
                    obj.anchors.size = Screen('TextSize',obj.windowPtr);                                            
                   
                    [lx, ly] = getTextCenter(obj.windowPtr, obj.anchors.text{1},...
                    obj.scale.cap.startL(1),obj.scale.cap.startL(2)-obj.anchors.vspace);
                    [rx, ry] = getTextCenter(obj.windowPtr, obj.anchors.text{2},...
                    obj.scale.cap.startR(1),obj.scale.cap.startR(2)-obj.anchors.vspace);
                else
                    obj.anchors.size = ip.Results.anchorSize;
                    defSize = Screen('TextSize',obj.windowPtr, obj.anchors.size);
                    
                    [lx, ly] = getTextCenter(obj.windowPtr, obj.anchors.text{1},...
                    obj.scale.cap.startL(1),obj.scale.cap.startL(2)-obj.anchors.vspace);
                    [rx, ry] = getTextCenter(obj.windowPtr, obj.anchors.text{2},...
                    obj.scale.cap.startR(1),obj.scale.cap.startR(2)-obj.anchors.vspace);
                    
                    Screen('TextSize',obj.windowPtr,defSize);                  
                end

                obj.anchors.Lcoords = [lx, ly];
                obj.anchors.Rcoords = [rx, ry];
                %Anchor color is tied to scale color if not provided
                if isempty(ip.Results.anchorColor) 
                    obj.anchors.color = Scolor;
                else
                    obj.anchors.color = ip.Results.anchorColor;
                end
            end
        end
        
        function obj = addGlassBound(obj,bound)
            % Updates a vas object's bounds such that a sliding cursor will
            % appear to be have a "glass ceiling" i.e. won't be able to move
            % past a specific point on the scale that is less than the max bound
            % can be expressed a proportion of the total scale length (0-1)
            % Usage:
            %
            % scale_var = scale_var.addGlassBounds(rightBound,leftBound)
            
            %Update the cursor bounds
            reducedLength = obj.scale.main.length*bound;
            obj.cursor.xmax = obj.cursor.xmin + reducedLength;
            obj.cursor.hasGlassBound = 1;
        end
        
        function obj = removeGlassBound(obj)
            % Updates a vas object by removing any bounds on it
            % Usage:
            % 
            % scale_var = scale_var.removeGlassBound
            
            %Update the cursor bounds
            obj.cursor.xmax = obj.scale.main.end(1);
            obj.cursor.hasGlassBound = 0;
        end
        
        
        function obj = updatePos(obj,x, y)
            % Updates a vas object's draw position given a new x and y coordinate
            % Usage:
            %
            % scale_var = scale_var.updatePose(newX,newY);
            
            %Update scale position
            obj.scale.main.start = [x-obj.scale.main.length/2; y];
            obj.scale.main.end = [x+obj.scale.main.length/2; y];
            obj.scale.cap.startL = [obj.scale.main.start(1); y-obj.scale.cap.length/2];
            obj.scale.cap.endL = [obj.scale.main.start(1); y+obj.scale.cap.length/2];
            obj.scale.cap.startR = [obj.scale.main.end(1); y-obj.scale.cap.length/2];
            obj.scale.cap.endR = [obj.scale.main.end(1); y+obj.scale.cap.length/2];
            
            %Update cursor position, probably can just based this on xmax-xmin
            %instead of dealing with a glass bounds boolean but it might be
            %nice to have that property for some reason, so this is a little
            %hokey
            
            %Check if there's a glass bound
            if obj.cursor.hasGlassBounds
                reducedLength = obj.cursor.xmax-obj.cursor.xmin;
            end
            obj.cursor.xmin = obj.scale.main.start(1);
            if obj.cursor.hasGlassBounds
                obj.cursor.xmax = obj.cursor.xmin + reducedLength;
            end
            obj.cursor.length = obj.scale.cap.length;
            obj.cursor.start = [x; obj.scale.cap.startL(2)];
            obj.cursor.end = [x; obj.scale.cap.endL(2)];

            %Update anchor positions if there are any
            if length(obj.anchors.text) > 1
                 defSize = Screen('TextSize', obj.windowPtr,obj.anchors.size);
                [lx, ly] = getTextCenter(obj.windowPtr, obj.anchors.text{1},...
                    obj.cursor.xmin,obj.scale.cap.startL(2)-obj.anchors.vspace);
                [rx, ry] = getTextCenter(obj.windowPtr, obj.anchors.text{2},...
                    obj.cursor.xmax,obj.scale.cap.startR(2)-obj.anchors.vspace);
                Screen('TextSize',obj.windowPtr,defSize);
                obj.anchors.Lcoords = [lx, ly];
                obj.anchors.Rcoords = [rx, ry];
            end
        end
        
        function obj = updateAnchors(obj,varargin)
            % Adds or removes anchors to a vas object
            %
            % To remove anchors:
            %
            % Simply call this method with no arguments, e.g.:
            % scale_var = scale_var.updateAnchors;
            %
            % To add anchors:
            %
            % Call this method with 1 or 2 arguments:
            % 
            % anchors= 1x2 cell array of anchors strings
            % color = optional 3x1 rgb vector for anchor color text
            % E.g.
            % scale_var = scale_var.updateAnchors({'Not at all' 'Very Much'},[0;0;0])
                       
            ip = inputParser;
            ip.CaseSensitive = false;
            ip.addOptional('anchors', {''},@iscell);
            ip.addOptional('color',[], @isnumeric);
            
            ip.parse(varargin{:});
            obj.anchors.text = ip.Results.anchors;
            
            %Change anchor color if provided, otherwise leave alone
            if ~isempty(ip.Results.color)
                obj.anchors.color = ip.Results.color;
            end
            
            %Check if we're removing or adding anchors
            if length(obj.anchors.text) > 1
                defSize = Screen('TextSize', obj.windowPtr,obj.anchors.size);
                [lx, ly] = getTextCenter(obj.windowPtr, obj.anchors.text{1},...
                    obj.scale.cap.startL(1),obj.scale.cap.startL(2)-obj.anchors.vspace);
                [rx, ry] = getTextCenter(obj.windowPtr, obj.anchors.text{2},...
                    obj.scale.cap.startR(1),obj.scale.cap.startR(2)-obj.anchors.vspace);
                Screen('TextSize',obj.windowPtr,defSize);
                obj.anchors.Lcoords = [lx, ly];
                obj.anchors.Rcoords = [rx, ry];
            end
        end
               
        function [rating] = showRating(obj,varargin)
            % Displays a rating on a vas object
            % Inputs:
            %
            % rating = a scalar value from 0-100, or the ouput of a getRating method call
            %
            % Optional args:
            %
            % noise = SD of normaly distributed noise to to add to the rating;
            %         defaults to 5
            %
            % color = a 3x1 rgb vector of the color the rating cursor should have;
            %         defaults to last known color of the cursor, which defaults to white
            %
            % Outputs:
            %
            % rating = the displayed rating, i.e. inputted rating + calculated noise
            
            ip = inputParser;
            ip.CaseSensitive = false;
            ip.addRequired('rating',@isnumeric);
            ip.addOptional('noise', 5, @isnumeric);
            ip.addOptional('color',[], @isnumeric);
            
            ip.parse(varargin{:});
            rating = ip.Results.rating;
            noise = ip.Results.noise;
            
            %Change cursor color if provided
            if ~isempty(ip.Results.color)
                obj.cursor.color = [ip.Results.color ip.Results.color];
            end
            
            %Calculate rating position
            rating = rating + (noise*randn(1,1));
            
            %Make sure we don't exceed the end points of the rating scale
            if rating > 100
                rating = 100;
            elseif rating < 0
                rating = 0;
            end
            
            obj.cursor.start(1) = ((rating/100)*(obj.cursor.xmax-obj.cursor.xmin))...
                + obj.cursor.xmin;
            obj.cursor.end(1) = obj.cursor.start(1);
            
            %Draw scale and rating
            Screen('DrawLines', obj.windowPtr, [obj.scale.main.start obj.scale.main.end...
                obj.scale.cap.startL obj.scale.cap.endL obj.scale.cap.startR...
                obj.scale.cap.endR obj.cursor.start obj.cursor.end], [obj.scale.width...
                obj.scale.width obj.scale.width obj.cursor.width], [obj.scale.colors...
                obj.cursor.color])
            
            %Draw anchors if any
            if length(obj.anchors.text) > 1
                defSize = Screen('TextSize', obj.windowPtr,obj.anchors.size);
                DrawFormattedText(obj.windowPtr, obj.anchors.text{1},...
                    obj.anchors.Lcoords(1), obj.anchors.Lcoords(2), obj.anchors.color);
                DrawFormattedText(obj.windowPtr, obj.anchors.text{2},...
                    obj.anchors.Rcoords(1), obj.anchors.Rcoords(2), obj.anchors.color);
                Screen('TextSize',obj.windowPtr,defSize);
            end
            
        end
        
        function [rating buttons] = getRating(obj)
            % Draws vas scale and collects a rating from a vas object
            % This should come before a Screen('Flip') call as it draws to the screen 
            % It's recommended to initially position the mouse at the mid-point of the 
            % scale via: SetMouse(vas.scale.main.midpoint(1), vas.scale.main.midpoint(2));
            %
            % For timing and logic, embed this along with stimulus drawing in a loop 
            % such as:
            %
            % Wait for a rating:
            % 
            % while (1)
            %     %Initially position the mouse at the mid-point of the vas
            %     SetMouse(X,Y);
            %         sTime = GetSecs;
            %         while (1)
            %             %Draw some stimulus
            %             Screen('DrawTexture',mainWin,imTex,[],imRect);
            %         
            %             %Draw some question
            %             DrawFormattedText(mainWin,qtext,qx,qy);
            %             
            %             %Wait for button click
            %             [rating, buttons] = vas.getRating;
            %             
            %             Screen('Flip',mainWin);
            %             if buttons(1)
            %                 RT = GetSecs-sTime;
            %                 break;
            %             end
            %         end
            % end
            %     
            % Continuous ratings:
            % 
            % Screen('PlayMovie'.....
            % while currentMovFrame < numFrames
            %     Screen('DrawTexture', mainWin, movFrame)
            %     [rating, buttons] = vas.getRating;;
            %     Screen('Flip',mainWin)
            % end
            
            %Get mouse coords
            [mouseX,~, buttons] = GetMouse(obj.windowPtr);
            
            %Update the cursor position
            obj.cursor.start(1) = mouseX;
            obj.cursor.end(1) = mouseX;
            
            %But correct it if it's beyond the scale
            if obj.cursor.start(1) > obj.cursor.xmax
                obj.cursor.start(1) = obj.cursor.xmax;
                obj.cursor.end(1) = obj.cursor.xmax;
            elseif obj.cursor.start(1) < obj.cursor.xmin
                obj.cursor.start(1) = obj.cursor.xmin;
                obj.cursor.end(1) = obj.cursor.xmin;
            end
            
            %Draw the scale and cursor
            Screen('DrawLines', obj.windowPtr, [obj.scale.main.start obj.scale.main.end...
                obj.scale.cap.startL obj.scale.cap.endL obj.scale.cap.startR...
                obj.scale.cap.endR obj.cursor.start obj.cursor.end], [obj.scale.width...
                obj.scale.width obj.scale.width obj.cursor.width], [obj.scale.colors...
                obj.cursor.color])
            
            %Draw anchors if there are any
            if length(obj.anchors.text) > 1
                defSize = Screen('TextSize', obj.windowPtr,obj.anchors.size);          
                DrawFormattedText(obj.windowPtr, obj.anchors.text{1},...
                    obj.anchors.Lcoords(1), obj.anchors.Lcoords(2), obj.anchors.color);
                DrawFormattedText(obj.windowPtr, obj.anchors.text{2},...
                    obj.anchors.Rcoords(1), obj.anchors.Rcoords(2), obj.anchors.color);
                Screen('TextSize', obj.windowPtr, defSize);
            end
            
            %Compute a rating
            rating = ((obj.cursor.start(1)-obj.cursor.xmin)/(obj.cursor.xmax-obj.cursor.xmin))*100;
        end
   
    end
   
end



