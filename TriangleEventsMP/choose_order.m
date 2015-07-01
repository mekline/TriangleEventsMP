function [info stimFiles fname] = choose_order(subj,run,counter,stimFolder)
%create item presentation order for eventsMP
%
%items come from 4 sets: A, B (event items) C, & D (control items).  
%
%The goal is to randomly create blocks of the right kind (see below) and assemble
%them into a megablock/run of the appropriate length & order, which will 
%depend on what run this is (1-5) and which counterbalance subj we're on (1-6)
%
%The blocks types are as follows; and each run wants 1 of each blocktype from each
%stim half (A-C, B-D)
%
%S - the same event movie, 4 times!
%M - all movies same manner, different paths & agents
%P - all movies same path, different agents & manners
%A - all movies same agent, different paths & manners
%D - all movies different on all 3 axes
%C - 4 control movies which differ on location and agent
%
%
%Then it takes the SMPADCSMPADC set, and reorgs it to construct whatever megablocks
%the square ordering says we're supposed to have on this run/counterbalance
%
% Here's an example of what we want: S-A M-B P-A A-B D-A C-B fix (flip a
% coin to decide which A/B to start with)
%
%
%   INPUT: subj = char (to get materials file); counter = block order
%   OUTPUT: 30x11 vector with presentation order 
%
%   items rand within blocks (from subj materials file)
%   (brute force no adjacent audio stories, everything else should be
%   sufficiently random by initial item division?)
%   saves final run order in data/, safe from over-write


% open materials file
[num,txt,raw] = xlsread('materials.xls');

info=1;
stimFiles=1;
fname = 1;


% extract items from the 4 sets into their own cellarrays

all_n = length(raw);
A = cell(64,7); %init A
B = cell(64,7); %init B
C = cell(16,7); %init C
D = cell(16,7); %init D

mysets = {A, B, C, D};
mynames = ['A','B','C','D'];
for k=1:4
    j = 0;
    for i = 2:all_n
        if isequal(raw{i,5},mynames(k))

            j=j+1;
            mysets{k}(j,:) = raw(i,:);
        end
    end
end

[A,B,C,D] = mysets{:};

%Draw items for each blocktype!  These are done non-independently, so 
%within a single run, we'll assert that any indiv video is seen only once. 

%XXX START HERE!
% 
% 
% % shuffle items, brute for no repeated stories 
% % NOTE: better check necessary?
% working = 1;
% while working
%     working = 0;
%     A = A(randperm(30),:); %random shuffle rows
%     A = sortrows(A,10); %sort by category
%     %check audio blocks have unique stories
%     for j = [1:4 9 10]
%         u = A((3*j-2):(3*j),:);
%         if isequal(u{1,6},u{2,6}) |  isequal(u{2,6},u{3,6}) | isequal(u{1,6},u{3,6})
%             working = 1;
%             continue
%         end
%     end
%     %check possible adjacent blocks have unique stories
%     if isequal(A{3,6},A{7,6})| isequal(A{27,6},A{1,6})| isequal(A{12,6},A{4,6})| isequal(A{6,6},A{28,6})
%         working = 1;
%         continue
%     end 
% end
% 
% 
% % get order blocks by counterbalancing option
% ITEMS = [1:6; 7:12; 13:18; 19:24; 25:30]; %A;B;C;...
% opts = [1 2 3 4 5; 
%         2 3 4 5 1;
%         3 4 5 1 2;
%         4 5 1 2 3;
%         5 1 2 3 4]; %ordering of conds (A B C ...; B C D ...; etc.)
% c = ITEMS(opts(counter,:),:);  %block counterbalancing order
% 
% 
% % place in final item order
% info = cell(30,11); %init order
% for i = 0:4
%     info([(1+ i*3):(3 + i*3) (28 - i*3):(30-i*3)],:) = A(c(i+1,:),:);
% end
% disp(['...item order created for subject ',subj,', run ',num2str(run)])
% 
% 
% % load movie names, sound files
% 
% stimFiles = [];
% for j = 1:30
%     if isequal(info{j,8},'audio')
%         
%         stimFiles(end+1).type = 'audio';
%         stimFiles(end).name = info{j,2};
%         
%         stimFolder
%         stimFiles(end).name
%         
%         
%         [y,freq] = audioread([stimFolder stimFiles(end).name]);
%         wavedata = y';
%         nrchannels = size(wavedata,1);
%         pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
%         PsychPortAudio('FillBuffer', pahandle, wavedata);
%         stimFiles(end).pahandle = pahandle;
%     else
%         stimFiles(end+1).type = 'movie';
%         stimFiles(end).name = info{j,2};
%  
%             
%     end
% end
% 
%         
% 
% % save item order, safe from over-write
% fname = ['data/',subj,'_items_run',num2str(run),'.csv'];
% x = 1;
% while exist(fname)==2
%     fname = ['data/',subj,'_items_run',num2str(run),'-x',num2str(x),'.csv'];
%     x=x+1;
% end
% 
% fid = fopen(fname,'w');
% fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',raw{1,:});
% for i = 1:30
%     fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%d\n',info{i,:});
% end
% fclose('all');
% disp(['...item order saved as ',fname])
% 
% end
% 
