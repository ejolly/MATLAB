function [resp, RT] = waitforSpecificKeys(keys,~)
    
% [resp, RT] = waitforSpecificKeys(keys, flag)
%     
% Shortcut function using high-precision KbQueueCheck to check for specific keys.
% Assumes keyboard is already established via KbQueueCreate.
%      
% keys = Either a single string or cell array of strings as input. Make sure keys are
% within the keylist that KbQueueCreate is listening for!
% flag = if a second arg is provided will convert responses to numerical values 
%
% resp = string (or double if flag provided) of the response key pressed down
% RT = float of time in seconds the key was pressed down since the function call
%     
% Examples:
% [resp, RT] = waitforSpecificKeys('space')
% [resp, RT] = waitforSpecificKeys({'1!','1','2@','2'},1) #output resp will be a double
%
% Authored EJ 2/15/15
% Added Windows specific code to prevent PTB halting EJ 2/24/15
  
    KbQueueFlush;
    startTime = GetSecs;
    while (1)
        [~, keyDown] = KbQueueCheck; 
        
        %Prevent Windows from treating PTB like it has "stopped responding"
        %Empty keyboard buffers, i.e. no response yet will make Windows
        %try to halt PTB. GetMouse will continually return something, 
        %keeping Windows happy.
        if IsWin
            GetMouse;
        end
        if any(keyDown(KbName(keys))) > 0 
            RT = GetSecs-startTime;
            resp = KbName(keyDown);
            break; 
        end    
    end
    if nargin > 1
        resp = str2double(resp(1));
    end
    KbQueueFlush;
end