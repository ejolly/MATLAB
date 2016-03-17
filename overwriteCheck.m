function varargout = overwriteCheck(data_dir,name)
% Quick function to check if a data file exists within a particular directory, or if a
% director exists in the matlab path. Directories should not have '.' in their names.
% If either exist then prompts a user about whether they want to overwrite the file/dir.
% Authored EJ 11/1/2011
% Added directory functionality - EJ 5/7/15

%Check if we're dealing with a directory or a file
if isempty(strfind(name,'.'))
    yesdir = 1;
else
    yesdir = 0;
end

if exist(fullfile(data_dir,name), 'file') == 2 || exist(fullfile(data_dir,name), 'dir') == 7
    if yesdir
        reply = input(...
            ['WARNING: That directory exists. Do you want to '...
            'overwrite it? (y) or (n)\n'],'s');
    else
        reply = input(...
            ['WARNING: That file exists, are you sure you want to '...
            'overwrite it? (y) or (n)\n'],'s');
    end
    
    %Wait for response
    while ~any(strcmp(reply,{'y','n'}))
        reply = input(...
            'Please enter (y) or (n)\n', 's');
    end
    
    %If yes and file, overwrite
    if strcmp(reply,'y') && ~yesdir
        fid = fopen(fullfile(data_dir, name), 'w');
        disp('OK OVERWRITING FILE...YOU WERE WARNED');
        %If yes and dir, overwrite
    elseif strcmp(reply,'y') && yesdir
        rmdir(fullfile(data_dir,name),'s');
        mkdir(data_dir,name);
        disp('OK OVERWRITING DIRECTORY...YOU WERE WARNED');
        %If no and dir, don't overwrite
    elseif yesdir
        disp('PROCEEDING WITH EXISTING DIRECTORY')
        %If no and file don't overwrite
    else
        disp('GOODBYE HAVE A NICE DAY!')
        fid = 0;
    end
    WaitSecs(.5);

    %Otherwise the file or dir don't exist so make them
elseif ~yesdir
    fid = fopen(fullfile(data_dir,name), 'w');
elseif yesdir
    mkdir(data_dir,name);
end

if ~yesdir
    if fid < 0
        error('Error: Can''t seem to find the data directory...')
    else
        varargout{1} = fid;
    end
elseif yesdir
    varargout{1} = fullfile(data_dir,name);
end

end