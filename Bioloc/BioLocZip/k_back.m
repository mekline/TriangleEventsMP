function out = k_back(project, optional_movie_path)


%     k_back(project, optional_movie_path)
%
%     howto use k_back:
%
%     the whole programm depends on
%     a .mat file, e.g. 'sts_motion.mat'
%       this file is saved under configs/ and then called through 
%       k_back('sts_motion'); in the commandline.
%     the .mat-file contains the following variables:
%
%     % ===================================================================
%     %% block-related variables
%     repeats = 1; % how many repeats should be built
%     back = 1; % one-/two-/three.. back-task ATTENTION: >1 not testet yet
%     fixation_time = 16; % time of fixation-time in seconds
%     blank_time = 0.25; % time of blank screen between movies in seconds
% 
%     % file-handling variables
%     mov_dir = 'movs/sts_motion'; % where the movies are
%                                  % if you want to have different movies
%                                  % for each run, just create folders like
%                                  % sts_motion_1, sts_motion_2 etc.
%     expected_dirs = 6; % i.e. conditions sfm_normal, sfm_scrambled, etc 
%     expected_movs_per_dir = 7;
% 
% 
%     % folder and name of the subject_file
%     file_directory = 'data/sts_motion'; % where the subject-files will be
%                                         % saved
%     file_prefix = 'sts_motion';
% 
%     % design of different runs; 0 means fixation cross
%     design = [0 1 2 3 4 5 6 0 6 5 4 3 2 1 0;
%               0 6 5 4 3 2 1 0 1 2 3 4 5 6 0;
%               0 2 4 1 5 6 3 0 3 6 5 1 4 2 0;
%               0 5 3 6 2 1 4 0 4 1 2 6 3 5 0;
%               0 3 1 2 6 4 5 0 5 4 6 2 1 3 0;
%               0 4 6 5 1 3 2 0 2 3 1 5 6 4 0;];
%
%     % whether the video should run in fullscreen-mode or not
%     fullscreen = 0; % 0 or 1
%     % ===================================================================
%
%
%     and of course the corresponding movies in the defined directories
%     e.g. movs/new_project/condition_1
%                                      /movie1.mov
%                                      /movie2.mov
%                                      /movie3.mov
%                           condition_2
%                                      /movie1.mov
%                                      /movie2.mov
%                                      ...
%
%
%     so if you want to create a new project, just load an old project-file
%     through: 
%     > clear all;
%     > load configs/sts_motion.mat;
%     % adjust the variables how you need them and save the file
%     > save configs/new_project.mat
%     
%     % then go ahead and create the folder-structure you need:
%     > mkdir movs/new_project;
%     > mkdir movs/new_project/condition_1; %etc
%     % and fill them with your movies
%     
%     % then you may start your program with:
%     > k_back('new_project');
%     
%     
%     written by Kilian Semmelmann <kilian@ksemmelm.de>




    load(fullfile('configs', sprintf('%s.mat', project)));
    
     
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DO NOT CHANGE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % checking whether config file has been loaded correctly
    if design == 0
        error('Error: Problems when loading the config file. Please check %s and try again.. (perhaps not all variables are set?)',fullfile('configs', project));
        clear all;
    end;
    
    % Setting this preference to 1 suppresses the printout of warnings.
    oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
    
    
    % Login screen
    prompt = {'Subject''s number:', sprintf('block number: 1-%d',size(design,1))};
    defaults = {'00', '1'};
    answer = inputdlg(prompt, sprintf('%s', file_prefix), 1, defaults);
    [subjectID, designID] = deal(answer{:});
    
    % other variables
    KbName('UnifyKeyNames');
    esc=KbName('ESCAPE');
    space=KbName('SPACE');
    designID = str2num(designID);
    fprintf('Starting run: %d\n', designID);
    subjectID = str2num(subjectID);
    run = design(designID, :);
    run_size = size(run, 2);
    % statistics
    stat_hit = 0;
    stat_fa = 0;
    stat_miss = 0;
    stat_cr = 0;
    mov_length = 0;
    
    % filename
    fname = sprintf(fullfile('%s', '%s_s%03d_r%d.txt'), file_directory, file_prefix, subjectID, designID);
    
    %%
    % generating struct with all directories and the containing files
    
    % the possibility to use different movie-directories with the same
    % project-config-file.
    if nargin == 2
        mov_dir = optional_movie_path;
    end;
    
    % the possibility to use alternative movies for each run
    alt_dir = sprintf('%s_%d', mov_dir, designID);
    if exist(alt_dir, 'file') == 7
        fprintf('Information: Alternate movie-directory has been found. Using ''%s'' as ressources.\n', alt_dir);
        mov_dir = alt_dir;
    end;
    
    if isdir(mov_dir)
        updir = dir(mov_dir);
    else
        error('Error: Directory ''%s'' not found - could not load movies.', mov_dir);
    end;
    cnt = 1;
    for i=1:size(updir,1)
        dir_name = updir(i).name;
        if strcmp(dir_name, '.') ~= 1 && strcmp(dir_name, '..') ~= 1 && isdir(fullfile(mov_dir, dir_name))
            dirs(cnt).name = dir_name;
            dirs(cnt).files = dir(sprintf(fullfile('%s', '%s', '*.mov'), mov_dir, dir_name));
            % display warning if there are not as many as expected_movs_per_dir
            movs_per_dir = size(dirs(cnt).files, 1);
            if  movs_per_dir ~= expected_movs_per_dir
                fprintf('Warning: %s contains %d files instead of %d\n', dir_name, movs_per_dir, expected_movs_per_dir);
            end;
%             if movs_per_dir > expected_movs_per_dir
%                 fprintf('Information: %s contains too many movies. Restricting to the use of just %d instead of all %d files.\n', dir_name, expected_movs_per_dir, movs_per_dir);
%                 movs_per_dir = expected_movs_per_dir;
%             end;
            dirs(cnt).size = movs_per_dir;
            cnt = cnt + 1;
        end;
    end;
    % display warning if there are not as many as expected_dirs
    if size(dirs, 2) < 1
        error('Error: no movie-directories within %s', mov_dir);
    else
        dirs_no = size(dirs, 2);
    end;
    if dirs_no ~= expected_dirs
        if dirs_no == 0
            error('Error: No directory found.');
        else
            fprintf('Warning: %d directories found instead of %d\n', dirs_no, expected_dirs);
        end;
    end;

    % check whether design-size matches number of directories
    % different checks because of 0 = fixation
    design_size = size(unique(run),2);
    first = unique(run);
    if dirs_no < design_size-1 && first(1) == 0
        error(sprintf('Error: %d directories found, %d needed for design', dirs_no, design_size-1));
    elseif dirs_no < design_size && first(1) == 1
        error(sprintf('Error: %d directories found, %d needed for design', dirs_no, design_size));
    end;


    %%
    % randomizing movies, adding n-back-task
    max_size = max([dirs(:).size]);
    for block=1:run_size
        condition = run(block); % number of condition, depending on design
        if condition ~= 0
            files_no = dirs(condition).size;
            if files_no > 0
                % randomize order of movies, then add a repeated one
                file_order = randperm(numel(dirs(condition).files));
                if repeats > 0
                    for repeat=1:repeats
                        files_no = size(file_order,2);
                        % leprechaun defines the position of the treasure .. eh repeated
                        % stimulus for the n-back task
                        leprechaun = randi(files_no);
                        % new concatination of file-order with doubled stimulus
                        clear file_order_new;
                        file_order_new = [file_order(1:leprechaun+back-1) file_order(leprechaun) file_order(leprechaun+back:files_no)];
                        clear file_order;
                        file_order = file_order_new;
                    end;
                end;
                % we have to keep the matriz even; therefore we need to
                % fill the rest up with zeros
                if size(file_order,2) < max_size
                    file_order = [file_order zeros(1,max_size-size(file_order,2))];
                end;
                order(block,:) = file_order;
            end;
        else
            order(block,:) = zeros(1,max_size+repeats);%zeros(1,dirs(1).size+repeats);
        end;
    end;
    
    
    %%
    % generating subject-file, check whether it could generated etc.
    % first check whether the folder exists
    if exist(file_directory) ~= 7
        fprintf('Warning: directory %s does not exist. Trying to create it..\n', file_directory);
        mkdir(file_directory);
    end;
    
    fileproblem = 0;
    while exist(fname, 'file') == 2 
        fileproblem = input('Warning: That file already exists\n     (1) append a .x \n     (2) overwrite \n     (3) abort (default)\n');
        if isempty(fileproblem) || fileproblem == 3
            error('Error: File already exists; aborting..');
        elseif fileproblem == 1
            fname = [fname '.x'];
        elseif fileproblem == 2
            delete(fname);
        end;
    end;
    file = fopen(fname,'w+');
    if(file == -1)
        error('Error: could not open %s', fname);
    end;
    
    fprintf(file, '%s \t\t %s \t %s \t\t %s \n', 'start', 'button', 'reaction', 'moviename');
    
    
    
    
    %%
    % start general psychtoolbox-stuff
    try
        %AssertOpenGL;

        % Open onscreen window:
        screenNum = max(Screen('Screens'));  %Highest screen number is most likely correct display
        [wPtr, rect] = Screen('OpenWindow', screenNum);
        center = [rect(3)/2 rect(4)/2];
        black = BlackIndex(wPtr);
        white = WhiteIndex(wPtr);
        HideCursor;

        % Clear screen to background color:
        Screen('FillRect', wPtr, black);
        Screen(wPtr, 'TextSize', 20);
        text = sprintf('waiting for trigger..');
        Screen('DrawText', wPtr, text, center(1)-200,center(2)-20,white);
        Screen(wPtr, 'Flip');
    catch
        % Error handling: Close all windows and movies, release all ressources.
        ShowCursor;
        Screen('Preference', 'SuppressAllWarnings',oldEnableFlag); 
        Screen('CloseAll');
        psychrethrow(psychlasterror);
    end;

    
    %%
    %{
    % wait for Scanner-input
    [keyIsDown, secs, keyCode] = KbCheck; 
    %while ~keyCode(KbName('p'))  
    while ~keyCode(KbName('=+')) && ~keyCode(KbName('+')) && ~keyCode(KbName('=')) 
        [keyIsDown, secs, keyCode] = KbCheck;
        
    end;
    %}
    
    FlushEvents;
    while 1  % wait for the 1st trigger pulse
        trig = GetChar;
        if trig == '+'
            t_exp_start = GetSecs;
            break
        end
    end
    
    %%
    % LOOP IT, BABY
    % start experiment
    t_exp_start = GetSecs;
    t_end = t_exp_start;
    preloading = 0;
    for block=1:run_size
        condition = run(block); % number of condition, depending on design
        movies_no = size(order(block,:),2);
        if condition == 0
            % fixation condition
            t_end = t_end + fixation_time;
            fprintf(file, '%4.3f \t\t 0 \t\t\t 0 \t\t\t\t fixation cross \n', GetSecs-t_exp_start);
            Screen(wPtr,'FillRect',black);
            Screen('FillRect',wPtr,128, CenterRect([0 0 16 4],rect));
            Screen('FillRect',wPtr,128,CenterRect([0 0 4 16],rect));
            Screen('Flip', wPtr);
            while GetSecs < t_end
                % preloading next movie
                if ~preloading && block+1 <= run_size && run(block+1) ~= 0
                    preloading = 1;
                    next_movieid = order(block+1,1);
                    next_moviename = fullfile(mov_dir, dirs(run(block+1)).name, dirs(run(block+1)).files(next_movieid).name);
                    disp(next_moviename);
                    Screen('OpenMovie', wPtr, next_moviename, 1);
                    %fprintf('fix-preloading %s\n', next_moviename);
                end;
            end;
        else
            files_no = dirs(condition).size;
            if files_no > 0
                % fetch every image out of the movie and show it
                % meanwhile catch buttonpresses and save it to file
                for movie=1:movies_no
                    t_mov_start = GetSecs-t_exp_start;
                    try
                        buttonpress = 0;
                        t_mov_start = GetSecs;
                        t_reaction = t_mov_start;
                        
                        % Open movie file and retrieve basic info about movie:
                        movieid = order(block, movie);
                        moviename = fullfile(mov_dir, dirs(condition).name, dirs(condition).files(movieid).name);
                        [moviePtr movieDuration movieFps movieWidth movieHeight movieCount] = Screen('OpenMovie', wPtr, moviename);
                        Screen('SetMovieTimeIndex', moviePtr, 0);
                        [nDroppedFrames]=Screen('PlayMovie', moviePtr, 1);

                        mov_length = mov_length + floor(movieDuration);
                        t_end = t_end + floor(movieDuration);
                        preloading = 0;
                        
                        
                        while GetSecs < t_end
                            [tex pts] = Screen('GetMovieImage', wPtr, moviePtr, 1);
                            % Valid texture returned?
                            if tex <= 0
                                break;
                            end;
                            
                            % Draw the new texture immediately to screen:
                            if fullscreen == 1
                                Screen('DrawTexture', wPtr, tex, [], rect);
                            else
                                Screen('DrawTexture', wPtr, tex);
                            end;
                            Screen('Flip', wPtr);

                            % preloading next movie
                            % within same condition
                            if ~preloading && movie+1 <= movies_no
                                next_movieid = order(block,movie+1);
                                if next_movieid ~= 0
                                    preloading = 1;
                                    next_moviename = fullfile(mov_dir, dirs(condition).name, dirs(condition).files(next_movieid).name);
                                    Screen('OpenMovie', wPtr, next_moviename, 1);
                                else
                                    movie = movies_no;
                                end;
                            end;
                            
                            % next condition
                            if ~preloading && movie+1 > movies_no && block+1 <= run_size && run(block+1) ~= 0
                                preloading = 1;
                                next_movieid = order(block+1,1);
                                next_moviename = fullfile(mov_dir, dirs(run(block+1)).name, dirs(run(block+1)).files(next_movieid).name);
                                Screen('OpenMovie', wPtr, next_moviename, 1);
                            end;
                            
                            
                            % watching for input from user
                            [keyIsDown,secs,keyCode]=KbCheck;
                            if (keyIsDown==1 && ~keyCode(KbName('=+')) && ~keyCode(KbName('+')) && ~keyCode(KbName('=')))
                                if(keyCode(esc))
                                    break;
                                end;
                                t_reaction = GetSecs;
                                buttonpress = KbName(keyCode);
                            end;
                            Screen('Close', tex);
                        end
                        
                        
                        % save stuff
                        %fprintf('block %d/%d - movie %d/%d - movie %d/%s - button: %d\n', block, run_size, movie, movies_no, movieid, moviename, buttonpress);
                        fprintf(file, '%4.3f \t\t %s \t\t\t %4.3f \t\t\t %s \n', t_mov_start-t_exp_start, num2str(buttonpress), t_reaction-t_mov_start, moviename);

                        % do the statistics
                        if movie-back > 0 && back > 0
                            if strcmp(num2str(buttonpress), '0') == 0 && order(block,movie-back) == movieid
                                % HIT
                                stat_hit = stat_hit + 1;
                            elseif strcmp(num2str(buttonpress), '0') == 0 && order(block,movie-back) ~= movieid
                                % FALSE ALARM
                                stat_fa = stat_fa + 1;
                            elseif strcmp(num2str(buttonpress), '0') == 1 && order(block,movie-back) == movieid
                                % MISS
                                stat_miss = stat_miss + 1;
                            elseif strcmp(num2str(buttonpress), '0') == 1 && order(block,movie-back) ~=movieid
                                % CORRECT REJECTION
                                stat_cr = stat_cr + 1;
                            else
                                % SOMETHING WENT WRONG
                                fprintf('Warning: Could not process user-response at block %d, movie %d (buttonpress: %d, movieid: %d, lastmovieid: %d)\n', block, movie, buttonpress, movieid, lastmovieid);
                            end;
                        elseif strcmp(num2str(buttonpress), '0') == 0
                            % FALSE ALARM, of course
                            stat_fa = stat_fa + 1;
                        else 
                            % CORRECT REJECTION, obv.
                            stat_cr = stat_cr + 1;
                        end;
                        
                        % Close moviePtr object:
                        Screen('CloseMovie', moviePtr);
                        % blank the screen
                        Screen(wPtr, 'Flip');
                        t_end = t_end + blank_time;
                        while GetSecs < t_end; end;
                    catch
                        % Error handling: Close all windows and movies, release all ressources.
                        ShowCursor;
                        Screen('Preference', 'SuppressAllWarnings',oldEnableFlag); 
                        Screen('CloseAll');
                        psychrethrow(psychlasterror);
                    end;
                    % ugly hack to stop Matlab to reset the loop-counter
                    if movie == movies_no
                        break;
                    end
                end;
            end;
        end;
    end;

    %% 
    % finish and clean up
    t_exp_end = GetSecs;
    accuracy = stat_hit / (stat_hit+stat_miss);
    fprintf(file, '%4.3f \t\t 0 \t\t\t 0 \t\t\t\t end \n', t_exp_end-t_exp_start);
    fprintf(file, '\n\n');
    fprintf(file, 'Hits: %d\n', stat_hit);
    fprintf(file, 'False Alarms: %d\n', stat_fa);
    fprintf(file, 'Misses: %d\n', stat_miss);
    fprintf(file, 'Correct Rejections: %d\n', stat_cr);
    fprintf(file, '\n\n');
    fprintf(file, 'Overall Accuracy: %3.4f\n', accuracy);
    fprintf(file, '\n\n');
    
    % calculating loss of time
    time = (sum(run~=0)*(movs_per_dir+repeats)*(blank_time))+mov_length+fixation_time*sum(run==0);
    fprintf('run: %5.5f, calc: %5.5f => time-loss: %5.5f \n', t_exp_end-t_exp_start, time, t_exp_end-t_exp_start-time);
    fprintf(file, 'run: %5.5f, calc: %5.5f => time-loss: %5.5f \n', t_exp_end-t_exp_start, time, t_exp_end-t_exp_start-time);
    fclose(file);

    % % restore preferences to the old level.
    Screen('Preference', 'SuppressAllWarnings',oldEnableFlag); 
    ShowCursor;
    Screen('CloseAll');
