function gestures_exp(subj, run, counter)

%This is the original! Only changes made by MK are simple PTB
%and path changes to make it run on my system. 

%Screen('Preference', 'SkipSyncTests', 1)

% check inputs
assert(ischar(subj) && run<6 &&counter<6, 'INCORRECT INPUTS -- subj: str (same as opt2), run: 1-5, counter: 1-5')

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

% constants
trialDur = 7.0;
fixDur = 16.0;
black = 0;

% get item order
%stimFolder = '/Users/Shared/Experiments/ev/gestures/gestureStims_normalized/';
stimFolder = [pwd '/gestureStims_normalized/'];

[info moviefiles fname] = choose_order(subj,run,counter,stimFolder);

%MKEdit
moviefiles = struct('name', {'02_G_CG_Bee_2_NF.ogv','03_G_CG_Bee_3_NF.ogv'}, 'type',{'movie','movie'}, 'pahandle',{[], []});


% save trial onset info
trial_types = cell(33,2);
trial_types(:,1) = {' '};
trial_types([1 17 33],1) = {'fix'};
trial_types([2:16 18:32],1) = info(:,8);
CUTOFF = ones(30,1);
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
