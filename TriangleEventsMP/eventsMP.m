function eventsMP(subj, counter, run)
%Melissa Kline 7/2015
%Main function for running eventsMP.  Based on the langloc/ gestures script mostly. 
%
%EventsMP is an adaptation experiment targeting high-level representations
%of events in language and other regions.  It involves a series of simple
%animated movies featuring a cartoon agent (A) moving along a path (P) with
%some distinctive manner (M). Code for generating these movies can be found
%at www.github.com/mekline/MannerPath/.
%
%The blocks/conditions of interest involve different *sequences* of
%these movies that vary on some, all or none of these dimensions, plus a 
%control condition with a still agent plus some low-level controls for
%relative motion (made possible by having *all* movies drift around in a
%Ken-Burnsy way.)
%
%See choose_order.m for details of how blocks are constructed. Block types
%in this experiment include all-same (S, e.g. 1_rotate_around.mpg repeated
%4 times), all-diff (D), and 3 conditions with a single feature fixed and the
%others varying (M,P,A, named for what stays constant through the block).
%
%In order for each block type to be presented 10 times, each participant
%should see 60 blocks; this is broken up into 5 runs of 12 blocks each.
%Subsequent blocks for a subject are guaranteed to be ordered nicely,
%but the items/block construction are randomly generated each time, so 
%repetition of individual movies is possible/likely (but not on adjacent
%blocks). 
%
%Timing info: Each movie is 6.0 seconds long; movies should be presented
%with a small gap (0.5) between each. Movies are preloaded to prevent
%overly bad buffering delays. Blocks are lumped into megablocks, with
%fixation periods at the beginning, middle and end of the experiment
%lasting for 16.0 seconds. Thus each run is 12*(4*6.5) + 3*(16.0) = 360
%seconds = 6 minutes long = 180 TR.
%
%Inputs: 
%subj = subject id (string)
%counter = counterbalancing assignment of this subject (int 1-6)
%run = run # (int 1-5)
%
%On each run, outputs:
%subj_items_run1.csv - the trials run this time, plus all the info I could
%think of that one might care about for each trial.
%
%subj_items_run1_onsets.csv - the actual onsets of each trial and the
%intended onsets of each trial (these should be very close to one another). 



% check inputs and other things
assert(ischar(subj) && run<6 &&counter<7, 'INCORRECT INPUTS -- subj: str ID, run: 1-5, counter: 1-6')


file_to_save = [pwd '/data/' subj,'_c', num2str(counter),'_onsets_run',num2str(run),'.csv'];

% Error message if data file already exists.
if exist(file_to_save,'file');
    
    error('myfuns:eventsMP:DataFileAlreadyExists', ...
        'The data file already exists for this subject/run!');
end

%TO ADD
% The second & subseqent runs should have the same value of counter as the first
% run for that subject, and the runs should go in order!
if run > 1,  
    %Find out what my counterbalancing is supposed to be.
    %And what the latest run was. 
    %     if exist([DATA_DIR filesep 'kan_langloc_' subj_id '_fmri_run' num2str(1) '_data.mat'],'file'),        
    %error('myfuns:kanwisher_langloc_2conds_main_fmri:Run1DoesntExist',...
    %         'Run 1 does not yet exist.');
    
end


% constants
num_of_trials = 48;
num_of_fix = 3.0;
trialDur = 6.5; %Movies are 6sec long, add a .5 sec buffer
fixDur = 16.0;
black = [0 0 0];
white = [255 255 255];

% get item orders for this run
stimFolder = [pwd '/movies/pilot/'];
[info moviefiles fname] = choose_order(subj,run,counter);

% save (intended/ideal) trial onset info, plus trial numbers to facilitate
trial_onsets = cell(51,4);
trial_onsets(1:51, 1) = {'trial'};
trial_onsets([1 26 51],1) = {'fix'};
CUTOFF = ones(48,1); %not sure what this is for yet


% PTB setup
AssertOpenGL;
InitializePsychSound;
PsychDefaultSetup(2);
rand('state', sum(100*clock));
HideCursor;

% restrict keyboard
esc=KbName('ESCAPE');
trig1 = KbName('+');
trig2 = KbName('=+');
RestrictKeysForKbCheck([esc trig1 trig2]);

try
    
    % open screen
    screen = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    [win rect] = PsychImaging('OpenWindow', screen, white, []);
    
    % useful screen coordinates
    X = rect(RectRight);
    Y = rect(RectBottom);
    vidSq = [X/2-480 Y/2-270 X/2+480 Y/2+270]; %vid dimensions
    fixPt = [[1 1 1 1]*X/2 + [0 0 -1 1]*20;
        [1 1 1 1]*Y/2 + [-1 1 0 0]*20];
    
    %For debugging!!! A very short experiment
%     info = info(:,1:8);
%     moviefiles = moviefiles(:,1:8);    
%     echo on
%     moviecount = size(moviefiles,2)
%     echo off
    
    % total trials
    moviecount = size(moviefiles,2);
    
    % make video shader (mk is not sure what this is for but exp breaks
    % without)
    shader = CreateSinglePassImageProcessingShader(win, 'BackgroundMaskOut', [255 255 255]);
    
    % wait for trigger
    Screen('TextSize', win, 32);
    DrawFormattedText(win,'waiting for trigger +','center','center',black);
    Screen(win, 'Flip', 0);
    
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        assert(~keyCode(KbName('ESCAPE')),'...ESCAPE to quit early');
        if keyCode(KbName('=+')) | keyCode(KbName('+'))==1
            break
        end
    end
    
    % timestamp experiment start
    fprintf('Experiment started!');
    expStart = GetSecs;
    trial_onsets{1,2} = expStart;
    
    % Show fixation block
    iteration = 0;
    
    Screen(win, 'DrawLines', fixPt,2,black);
    Screen(win, 'Flip', expStart);
    
    %...and wait for the fixation period to finish out if time left
    while GetSecs < expStart+fixDur
        [keyIsDown,secs,keyCode] = KbCheck;
        assert(~keyCode(KbName('ESCAPE')),'...ESCAPE to quit early')
    end
    
    % Update intended timing in prep for the first trial...
    t_perfect = expStart+fixDur-trialDur; %Starts this way so trialDur can be iterated each time to find next onset
    trial_onsets{1,3} = t_perfect;
    
    
    % trial loop
    while iteration<moviecount
        % get item info for this iteration
        iteration = iteration + 1;
        stim = moviefiles(iteration);
        trial_onsets{iteration+ceil(iteration/24),1} = stim.type; %This is some clever math that adds 1 to iteration when we haven't gotten to the middle fix and 2 after we have!
        
        %Make sure the screen is blank at the beginning of the trial
        Screen('FillRect', win, white); % this blanks the screen
        Screen('Flip', win);
        
        stim.name %print out in the bg in case of breaks
        [movie movieduration fps imgh imgw] = Screen('OpenMovie', win, [stimFolder stim.name]);
        
        % wait for intended onset time of trial
        while GetSecs<t_perfect+trialDur
            [keyIsDown,secs,keyCode]=KbCheck;
            assert(~(keyIsDown==1 && keyCode(esc)),'ESC: quit early');
        end

        % start movie
        Screen('PlayMovie', movie, 1, 0, 1.0);

        % How long did that take to start? (update timing)
        t_perfect = t_perfect+trialDur;
        trial_onsets{iteration+ceil(iteration/24),2} = GetSecs;
        trial_onsets{iteration+ceil(iteration/24),3} = t_perfect;
        trial_onsets{iteration+ceil(iteration/24),4} = iteration; %the current trial number!

        % play movie
        while GetSecs<t_perfect+trialDur %if we bump into the next movie's timeslot, maybe cut movie short?
            [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
            assert(~(keyIsDown==1 && keyCode(esc)),'ESC: quit early');

            if (imgw>0) && (imgh>0)
                tex = Screen('GetMovieImage', win, movie, 0);
                if tex < 0
                    CUTOFF(iteration,1) = 0;
                    break;
                end
                if tex == 0
                    WaitSecs('YieldSecs', 0.005);
                    continue;
                end
                Screen('DrawTexture', win, tex, [], [], [], [], [], [], shader);
                Screen('Flip', win);
                Screen('Close', tex);
            end;

        end;
        Screen('Flip', win);
        Screen('PlayMovie', movie, 0); % stop movie
        Screen('CloseMovie', movie); % close movie

        if mod(iteration,24)==0 % after trials 24, 48, do a fixation period!
            % wait for onset of fixation block

            while GetSecs<t_perfect+trialDur
                [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
                assert(~(keyIsDown==1 && keyCode(esc)),'ESC: quit early');
            end
            
            % update timing
            t_perfect = t_perfect+trialDur;           
            trial_onsets{iteration+ceil(iteration/24)+1,2} = GetSecs;
            trial_onsets{iteration+ceil(iteration/24)+1,3} = t_perfect;
            % update screen
            Screen(win, 'DrawLines', fixPt,2,black);
            Screen(win, 'Flip');
            while GetSecs < t_perfect+fixDur
                [keyIsDown,secs,keyCode] = KbCheck;
                assert(~keyCode(KbName('ESCAPE')),'...ESCAPE to quit early');
            end
            t_perfect = t_perfect+fixDur-trialDur;
            
            

        end
        
    end;
    % end timing
    fprintf('Experiment finished successfully!');
    expEnd = GetSecs;
    
    fprintf('Total duration: ');
    total = expEnd - expStart

    % save trial onsets
    header = {'trial_type','measured_onset','perfect_onset', 'trialnum'};

    fid = fopen(file_to_save,'w');
    fprintf(fid,'%s,%s,%s,%s\r\n',header{1,:});
    for i = 1:51 %48 trials + 3 fix periods
        fprintf(fid,'%s,%f,%f, %d\r\n',trial_onsets{i,:});
    end
    
    % close all
    fclose('all')
    
    Screen('CloseAll');
    
    ShowCursor;

    return;
catch % save onset times, show error
    % end timing
    'Experiment finished - Exited on error.'
    expEnd = GetSecs
    
    %debug
    expStart = 2;
    
    fprintf('Total duration: ');
    total = expEnd - expStart

   
    
    % save trial onsets
    header = {'trial_type','measured_onset','perfect_onset', 'trialnum'};

    fid = fopen(file_to_save,'w');
    fprintf(fid,'%s,%s,%s,%s\r\n',header{1,:});
    for i = 1:48
        fprintf(fid,'%s,%f,%f, %d\r\n',trial_onsets{i,:});
    end
    
    % close all
    fclose('all')
    
    Screen('CloseAll');
    
    ShowCursor;
    psychrethrow(psychlasterror);
end
