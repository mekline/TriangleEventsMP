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
%the square ordering says we're supposed to have on this
%run/counterbalance.  As an extra constraint, blocks from the different
%stim halves should alternate so that movies don't reoccur nearby. 
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


%dummy output args, fix these up later!
info=1;
stimFiles=1;
fname = 1;

raw(:,4) = cellfun(@num2str, raw(:,4), 'UniformOutput', 0);
raw(:,3) = cellfun(@num2str, raw(:,3), 'UniformOutput', 0);

% extract items from the 4 sets into their own cellarrays

all_n = length(raw);
A = cell(64,5); %init A
B = cell(64,5); %init B
C = cell(16,5); %init C
D = cell(16,5); %init D

mysets = {A, B, C, D};
mynames = ['W','X','Y','Z'];
for k=1:4
    j = 0;
    for i = 2:all_n
        if isequal(raw{i,5},mynames(k))

            j=j+1;
            mysets{k}(j,:) = raw(i,:);
        end
    end
end

%Draw items for each blocktype (in subsets A and B)!  These are done non-independently: 
%within a single run, we'll assert that any indiv video is seen only once,
%and no dimensions of generalization will be repeated (e.g. 'rotate' can't
%be both the fixed manner and the manner of the S block in a run.)  

%Make a place to hold the rows of each block, plus block kind
myblocks = cell(48,6);

for i=1:2
    myset = mysets{i};  
    
    %The plan is to try to pick items from this subset to satisfy
    %all requirements of the blocks that come from this subset. 
    %Since this proceeds by randomly picking &
    %checking items, it will sometimes fail(?)  Wrap it up and retry
    %until we finally succeed!
    
    stillLooking = 1;
    
    while stillLooking
        
            used = 1:64; %64 available 'real' event movies/subset, used 
            %for indexing into the arrays.  Set to 0 when used.
            
            %%%%%
            %Make an S (all-same) block
            %%%%%%
            %%    
                
            %Get an initial choice (j), and reuse it!
            j = datasample(used, 1);
            used(j) = 0;
            trial = myset(j,:);
            trial{1,6} = 'S';
            for k=1:4 % 1:4 on iteration 1, 5-8 on iteration 2
                wheretoput = 4*(i-1) + k;
                myblocks(wheretoput,:) = trial(:);
            end

            %And save those manner & paths to prevent them from being used as a
            %fixed dimension anywhere else in this run!  
            fixManner = trial(2);
            fixPath = trial(3);
            fixAgent = trial(4);    
            %%
            
            %%%%%%
            %Make an M (manner-same) block
            %%%%%%     
            %%

            %Get an initial choice (j) - not used, not a fixed element
            %we're avoiding. 
            j=0;
            while j==0
                j = datasample(used, 1);
                if j== 0
                    continue;
                end
                trial = myset(j,:);
                if isequal(trial(2), fixManner)
                    j=0;
                end
            end
            used(j) = 0;

            %Now find 3 that share j's manner but nothing else.
            MtoFind = trial(2);
            PBanList = trial(3);
            ABanList = trial(4);
            found = j;

            %Extra bit so search through the subset won't always start at 1
            iterator = [1:64]; 
            r = randi([1 64]);%shift!
            iterator = iterator([r:64 1:r]);
            iter = 1;

            while (length(found) < 4) && (iter < 65)
                testfit = myset(iterator(iter),:);

                %Does it match? Must be: unused, not already on any ban lists for
                %this block
                if not(iterator(iter) == 0)
                    if ismember(testfit(2),MtoFind) && not(ismember(testfit(3), PBanList)) && not(ismember(testfit(4), ABanList)) 
                        found(end+1) = iterator(iter);
                        used(iterator(iter)) = 0;
                        PBanList(1,end+1) = testfit(3);
                        ABanList(1,end+1) = testfit(4);
                    end
                end
                %keep looking!
                iter = iter+1;
            end
            
            if length(found) < 4
                continue;
            end

            %Add M block to myblocks
            for k=1:4 
                trial = myset(found(k),:);
                trial{1,6} = 'M';
                %wheretoput = (i-1)*24 + 4 + k; % 5:8 on iteration 1, 29:32 on iteration 2
                wheretoput = 8 + 4*(i-1) + k; %9-12 on it1, 13-16 on it2
                myblocks(wheretoput,:) = trial(:);
            end           
            %%
            
            %%%%%            
            %Make a P (path-same) block
            %
            %(ugly code! this is just the mannerblock code modified slightly!)
            %%%%%
            %%
            
            %Get an initial choice (j) - not used, not a fixed element
            %we're avoiding. 
            j=0;
            while j==0
                j = datasample(used, 1);
                if j== 0
                    continue;
                end
                trial = myset(j,:);
                if isequal(trial(3), fixPath)
                    j=0;
                end
            end
            used(j) = 0;

            %Now find 3 that share j's path but nothing else.
            MBanList = trial(2);
            PtoFind = trial(3);
            ABanList = trial(4);
            found = j;


            %Extra bit so search through the subset won't always start at 1
            iterator = [1:64]; 
            r = randi([1 64]);%shift!
            iterator = iterator([r:64 1:r]);
            iter = 1;

            while (length(found) < 4) && (iter < 65)
                testfit = myset(iterator(iter),:);

                %Does it match? Must be: unused, not already on any ban lists for
                %this block
                if not(used(iterator(iter)) == 0)
                    if not(ismember(testfit(2),MBanList)) && ismember(testfit(3), PtoFind) && not(ismember(testfit(4), ABanList)) 
                        found(end+1) = iterator(iter);
                        used(iterator(iter)) = 0;
                        MBanList(1,end+1) = testfit(2);
                        ABanList(1,end+1) = testfit(4);
                    end
                end
                %keep looking!
                iter = iter+1;
            end
            
            if length(found) < 4
                continue;
            end
            
            %Add P block to myblocks
            for k=1:4 
                trial = myset(found(k),:);
                trial{1,6} = 'P';
                wheretoput = 16 + 4*(i-1) + k; %17-20 on it1, 21-24 on it2
                myblocks(wheretoput,:) = trial(:);
            end            
            %%
                      
            %%%%%%%
            %Make an A (agent-same) block
            %%%%%%%
            %%

            %Get an initial choice (j) - not used, not a fixed element
            %we're avoiding. 
            j=0;
            while j==0
                j = datasample(used, 1);
                if j== 0
                    continue;
                end
                trial = myset(j,:);
                if isequal(trial(4), fixAgent)
                    j=0;
                end
            end
            used(j) = 0;

            %Now find 3 that share j's agent but nothing else.
            MBanList = trial(2);
            PBanList = trial(3);
            AtoFind = trial(4);
            found = j;

            %Extra bit so search through the subset won't always start at 1
            iterator = [1:64]; 
            r = randi([1 64]);%shift!
            iterator = iterator([r:64 1:r]);
            iter = 1;

            while (length(found) < 4) && (iter < 65)
                testfit = myset(iterator(iter),:);

                %Does it match? Must be: unused, not already on any ban lists for
                %this block
                if not(used(iterator(iter)) == 0)
                    if not(ismember(testfit(2),MBanList)) && not(ismember(testfit(3), PBanList)) && ismember(testfit(4), AtoFind) 
                        found(end+1) = iterator(iter);
                        used(iterator(iter)) = 0;
                        MBanList(1,end+1) = testfit(2);
                        PBanList(1,end+1) = testfit(3);
                    end
                end
                %keep looking!
                iter = iter+1;
            end
            
            if length(found) < 4
                continue;
            end
            
            %Add A block to myblocks
            for k=1:4 
                trial = myset(found(k),:);
                trial{1,6} = 'A';
                wheretoput = 24 + 4*(i-1) + k; %25-28 on it1, 29-32 on it2
                myblocks(wheretoput,:) = trial(:);
            end
            %%

            %%%%%%%
            %Make an D (all-diff) block 
            %%%%%%%
            %%
            
            j=0;
            while j==0
                j = datasample(used, 1);
            end
            used(j) = 0;
            
            trial = myset(j,:);
            %Now find 3 that share NOTHING else.
            MBanList = trial(2);
            PBanList = trial(3);
            ABanList = trial(4);
            found = j;

            %Extra bit so search through the subset won't always start at 1
            iterator = [1:64]; 
            r = randi([1 64]);%shift!
            iterator = iterator([r:64 1:(r-1)]);
            iter = 1;

            while (length(found) < 4) && (iter < 65)
                testfit = myset(iterator(iter),:);

                %Does it match? Must be: unused, not already on any ban lists for
                %this block
                if not(used(iterator(iter)) == 0)
                    if not(ismember(testfit(2),MBanList)) && not(ismember(testfit(3), PBanList)) && not(ismember(testfit(4), ABanList)) 
                        found(end+1) = iterator(iter);
                        used(iterator(iter)) = 0;
                        MBanList(1,end+1) = testfit(2);
                        PBanList(1,end+1) = testfit(3);
                        ABanList(1,end+1) = testfit(4);
                    end
                end
                %keep looking!
                iter = iter+1;
            end
            
                        
            if length(found) < 4
                continue;
            end
            
            %Add D block to myblocks
            for k=1:4 
                trial = myset(found(k),:);
                trial{1,6} = 'D';
                wheretoput = 32 + 4*(i-1) + k; %33-36 on it1, 37-40 on it2
                myblocks(wheretoput,:) = trial(:);
            end
            %%

            %If we got here, we finished! Hooray!
            stillLooking = 0;
        
    end
end


for i=1:2 % Same thing, for the control blocks!
    myset = mysets{i+2}; 
    
    %As above, out of the set of possible items pick a set that meet the
    %requirements of each block.  This time we just need one block of all-
    %diff items (location and agent, there is no manner). Easy peasy!
    
    stillLooking = 1;
    
    while stillLooking
    
        used = 1:16;

        %%%%%%%
        %Make a C (cotrol) block 
        %%%%%%%
        %%

        j=0;
        while j==0
            j = datasample(used, 1);
        end
        used(j) = 0;

        trial = myset(j,:);
        %Now find 3 more items that share NOTHING else.
        MBanList = 0; %just being careful
        PBanList = trial(3);
        ABanList = trial(4);
        found = j;

        %Extra bit so search through the subset won't always start at 1
        iterator = [1:16]; 
        r = randi([1 16]);%shift!
        iterator = iterator([r:16 1:(r-1)]);
        iter = 1;

        while (length(found) < 4) && (iter < 16)
            testfit = myset(iterator(iter),:);

            %Does it match? Must be: unused, not already on any ban lists for
            %this block
            if not(used(iterator(iter)) == 0)
                if not(ismember(testfit(3), PBanList)) && not(ismember(testfit(4), ABanList)) 
                    found(end+1) = iterator(iter);
                    used(iterator(iter)) = 0;
                    PBanList(1,end+1) = testfit(3);
                    ABanList(1,end+1) = testfit(4);
                end
            end
            %keep looking!
            iter = iter+1;
        end


        if length(found) < 4
            continue;
        end

        %Add C block to myblocks
        for k=1:4 
            trial = myset(found(k),:);
            trial{1,6} = 'C';
            wheretoput = 40 + 4*(i-1) + k; %41-44 on it1, 45-48 on it2
            myblocks(wheretoput,:) = trial(:);
        end
        %%

        %if we got here, we assigned everything!
        stillLooking = 0;
    end
end



%Check what the block looks like during debug
%myblocks(1:48, 2:6);


%Blocks/items for this subject are chosen! Now to put them in the block
%order specified by the run + counterbalance scheme.  NOTE: as planned, 
%each participant will see 5 runs, for a total of 10 blocks per condition.
%There are 6 orderings of the stims below, so each person will miss one;
%counterbalancing should be set at 1-6. 

ITEMS = [1:8; 9:16; 17:24; 25:32; 33:40; 41:48]; %S;M;P;A;D;C
opts = [1 2 3 4 5 6; 
        2 3 4 5 6 1;
        3 4 5 6 1 2;
        4 5 6 1 2 3;
        5 6 1 2 3 4
        6 1 2 3 4 5]; %possible ordering of conds (A B C ...; B C D ...; etc.)
    
%Which row order should we take? That's a combo of run + counterbalancing!  
toUse = mod((run + counter), 6) + 1;
c = ITEMS(opts(toUse,:),:);  %block counterbalancing order


% place in final item order
info = cell(48,6); %init info 
%Flip a coin! Which data subset goes first this run? (WWWWXXXXWWWW etc.)

whichfirst = randi(2)-1;

for i = 0:5
    if mod(whichfirst+i,2) == 0
        info([(1+ i*4):(4 + i*4) (45 - i*4):(48-i*4)],:) = myblocks(c(i+1,:),:); %This counts inward - eg i=0 chooses 1st 4 and last 4
    else
        info([(45 - i*4):(48-i*4) (1+ i*4):(4 + i*4)],:) = myblocks(c(i+1,:),:);
    end
end

echo on
disp(['...item order created for subject ',subj])
disp(['subj counterbalancing ', num2str(counter), ', run ',num2str(run)])
echo off



% load movie names into a struct for easy access. (I dont' know, I guess
% the main script wants it that way....)

stimFiles = [];
for j = 1:48
    stimFiles(end+1).type = 'movie';
    stimFiles(end).name = info{j,1};
end

        

% save item order, safe from over-write
fname = ['data/',subj,'_items_run',num2str(run),'.csv'];
x = 1;
while exist(fname)==2
    fname = ['data/',subj,'_items_run',num2str(run),'-x',num2str(x),'.csv'];
    x=x+1;
end

%Add block number to info in case we need it!
blocknum = 1:48;
blocknum = ceil(blocknum/4);
info(:,7) = num2cell(blocknum);

fid = fopen(fname,'w');

headers = raw(1,:);
headers(end+1) = {'blocktype'};
headers(end+1) = {'blocknum'};


fprintf(fid,'%s,%s,%s,%s,%s,%s,%s\r\n',headers{:});
for i = 1:48
    fprintf(fid,'%s,%s,%s,%s,%s,%s,%d\r\n',info{i,:});
end
fclose('all');
disp(['...item order saved as ',fname])

end

