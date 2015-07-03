function eventsMP(subj, run, counter)
%Melissa Kline 7/2015
%Main function for running eventsMP.  Based on the langloc/ gestures script mostly. 
%
%EventsMP is an adaptation experiment targeting high-level representations
%of events in language and other regions.  It involves a series of simple
%animated movies featuring a cartoon agent (A) moving along a path (P) with
%some distinctive manner (M). Code for generating these movies can be found
%at www.github.com/mekline/MannerPath
%
%The blocks/conditions) of interest involve different *sequences* of
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
%some repetition is possible. 
%
%Inputs: 
%subj = subject id (string)
%run = run # (int 1-5)
%counter = counterbalancing assignment of this subject (int 1-6)
%
%On each run, outputs:
%subj_items_run1.csv - the trials run this time, plus all the info I could
%think of that one might care about for each trial.
%
%subj_items_run1_onsets.csv - the actual onsets of each trial and the
%intended onsets of each trial (these should be very close to one another). 



% check inputs and other things
assert(ischar(subj) && run<6 &&counter<7, 'INCORRECT INPUTS -- subj: str (same as opt2), run: 1-5, counter: 1-6')


file_to_save = [subj '_items_run' num2str(run) '_onsets.csv']; 

% Error message if data file already exists.
if exist([pwd '/data/' file_to_save],'file');
    
    error('myfuns:eventsMP:DataFileAlreadyExists', ...
        'The data file already exists for this subject/run!');
end

% The second & subseqent runs should have the same value of counter as the first
% run for that subject, and the runs should go in order!
% if run > 1,    
%     if exist([DATA_DIR filesep 'kan_langloc_' subj_id '_fmri_run' num2str(1) '_data.mat'],'file'),        
%         if subj_data.reversed ~= do_rev_order,            
%             error('myfuns:kanwisher_langloc_2conds_main_fmri:CounterDoesntMatch',...
%                 'You must use the same value of counter (counterbalancing) for all runs.');
%         end        
%     else        
%         error('myfuns:kanwisher_langloc_2conds_main_fmri:Run1DoesntExist',...
%             'Run 1 does not yet exist.');
%     end   
% end

% constants
num_of_trials = 48;
num_of_fix = 3;
trialDur = 7.0;
fixDur = 16.0;
black = 0;

% get item order
%stimFolder = '/Users/Shared/Experiments/ev/gestures/gestureStims_normalized/';
stimFolder = [pwd '/movies/pilot/'];

[info moviefiles fname] = choose_order(subj,run,counter,stimFolder);

%MKEdit
%moviefiles = struct('name', {'02_G_CG_Bee_2_NF.ogv','03_G_CG_Bee_3_NA.ogv'}, 'type',{'movie','movie'}, 'pahandle',{[], []});


% save trial onset info
trial_types = cell(33,2);
trial_types(:,1) = {' '};
trial_types([1 17 33],1) = {'fix'};
%trial_types([2:16 18:32],1) = info(:,8);
CUTOFF = ones(30,1);



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
    [win rect] = PsychImaging('OpenWindow', screen, [255 255 255], []);
    
    % useful screen coordinates
    X = rect(RectRight);
    Y = rect(RectBottom);
    vidSq = [X/2-480 Y/2-270 X/2+480 Y/2+270]; %vid dimensions
    fixPt = [[1 1 1 1]*X/2 + [0 0 -1 1]*20;
        [1 1 1 1]*Y/2 + [-1 1 0 0]*20];
    
    % make video shader
    shader = CreateSinglePassImageProcessingShader(win, 'BackgroundMaskOut', [255 255 255]);
    
    % total trials
    moviecount = size(moviefiles,2);
    
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
    expStart = GetSecs
    trial_types{1,2} = expStart;
    
    % fixation block
    iteration = 0;
    
    Screen(win, 'DrawLines', fixPt,2,black);
    Screen(win, 'Flip', expStart);
    while GetSecs < expStart+fixDur
        [keyIsDown,secs,keyCode] = KbCheck;
        assert(~keyCode(KbName('ESCAPE')),'...ESCAPE to quit early')
    end
    
    % update timing
    t_perfect = expStart+fixDur-trialDur;
    trial_types{1,3} = t_perfect;
    % trial loop
    while iteration<moviecount
        % get item info
        iteration = iteration + 1;
        stim = moviefiles(iteration);
        trial_types{iteration+ceil(iteration/15),1} = stim.type;
        Screen('Flip', win);
        if isequal(stim.type,'audio') % AUDIO TRIAL
            % start audio
            PsychPortAudio('Start', stim.pahandle, 1, 0, 1);
            
            % wait for onset of trial
            while GetSecs<t_perfect+trialDur
                
                [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
                assert(~(keyIsDown==1 && keyCode(esc)),'ESC: quit early');
            end
            
            % update timing
            t_perfect = t_perfect+trialDur;
            trial_types{iteration+ceil(iteration/15),2} = GetSecs;
            trial_types{iteration+ceil(iteration/15),3} = t_perfect;
            
            % play audio
            playing = 1;
            while playing
                
                [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
                assert(~(keyIsDown==1 && keyCode(esc)),'ESC: quit early');
                status = PsychPortAudio('GetStatus', stim.pahandle);
                if status.Active == 0 % close audio
                    PsychPortAudio('Close', stim.pahandle);
                    playing = 0;
                    CUTOFF(iteration,1) = 0;
                end
            end
            
        elseif isequal(stim.type,'movie') % MOVIE TRIAL
            % load movie
            stimFolder
            stim.name
            [movie movieduration fps imgw imgh] = Screen('OpenMovie', win, [stimFolder stim.name]);
            
            % wait for onset of trial
            while GetSecs<t_perfect+trialDur
                [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
                assert(~(keyIsDown==1 && keyCode(esc)),'ESC: quit early');
            end
            
            % start movie
            Screen('PlayMovie', movie, 1, 0, 1.0);
            
            % update timing
            t_perfect = t_perfect+trialDur;
            trial_types{iteration+ceil(iteration/15),2} = GetSecs;
            trial_types{iteration+ceil(iteration/15),3} = t_perfect;
            
            % play movie
            while GetSecs<t_perfect+trialDur %if lag: maybe cut movie short?
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
        end;
        
        if mod(iteration,15)==0 % after trials 15, 30
            % wait for onset of fixation block
            
            while GetSecs<t_perfect+trialDur
                [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
                assert(~(keyIsDown==1 && keyCode(esc)),'ESC: quit early');
            end
            
            % update timing
            t_perfect = t_perfect+trialDur;           
            trial_types{iteration+ceil(iteration/15)+1,2} = GetSecs;
            trial_types{iteration+ceil(iteration/15)+1,3} = t_perfect;
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
    fprintf('Experiment finished!');
    expEnd = GetSecs
    
    fprintf('Total duration: ');
    total = expEnd - expStart

    % save trial onsets
    onsetfile = [fname(1:end-4) '_onsets.csv'];
    header = {'trial_type','onset'};

    fid = fopen(onsetfile,'w');
    fprintf(fid,'%s,%s\n',header{1,:});
    for i = 1:33
        fprintf(fid,'%s,%f,%f\n',trial_types{i,:});
    end
    
    % close all
    fclose('all')
    
    Screen('CloseAll');
    
    ShowCursor;

    return;
catch % save onset times, show error
    % end timing
    fprintf('Experiment finished!');
    expEnd = GetSecs
    
    %debug
    expStart = 2;
    
    fprintf('Total duration: ');
    total = expEnd - expStart

   
    
    % save trial onsets
    onsetfile = [fname(1:end-4) '_onsets.csv'];
    header = {'trial_type','onset','perfect'};

    fid = fopen(onsetfile,'w');
    fprintf(fid,'%s,%s,%s\n',header{1,:});
    for i = 1:33
        fprintf(fid,'%s,%f,%f\n',trial_types{i,:});
    end
    
    % close all
    fclose('all')
    
    Screen('CloseAll');
    
    ShowCursor;
    psychrethrow(psychlasterror);
end
