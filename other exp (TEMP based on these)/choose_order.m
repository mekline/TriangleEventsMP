function [info stimFiles fname] = choose_order(subj,run,counter,stimFolder)
%create item presentation order
%
%   INPUT: subj = char (to get materials file); counter = block order
%   OUTPUT: 30x11 vector with presentation order
%
%   items rand within blocks (from subj materials file)
%   (brute force no adjacent audio stories, everything else should be
%   sufficiently random by initial item division?)
%   saves final run order in data/, safe from over-write


% open materials file
[num,txt,raw] = xlsread(['data/',subj,'_items_divided.xls']);

all_n = length(raw);

% extract items in run, store in A
A = cell(30,11); %init A

j = 0;
for i = 2:all_n
    if isequal(raw{i,11},run)
        j=j+1;
        A(j,:) = raw(i,:);
    end
end


% shuffle items, brute for no repeated stories 
% NOTE: better check necessary?
working = 1;
while working
    working = 0;
    A = A(randperm(30),:); %random shuffle rows
    A = sortrows(A,10); %sort by category
    %check audio blocks have unique stories
    for j = [1:4 9 10]
        u = A((3*j-2):(3*j),:);
        if isequal(u{1,6},u{2,6}) |  isequal(u{2,6},u{3,6}) | isequal(u{1,6},u{3,6})
            working = 1;
            continue
        end
    end
    %check possible adjacent blocks have unique stories
    if isequal(A{3,6},A{7,6})| isequal(A{27,6},A{1,6})| isequal(A{12,6},A{4,6})| isequal(A{6,6},A{28,6})
        working = 1;
        continue
    end 
end


% get order blocks by counterbalancing option
ITEMS = [1:6; 7:12; 13:18; 19:24; 25:30]; %A;B;C;...
opts = [1 2 3 4 5; 
        2 3 4 5 1;
        3 4 5 1 2;
        4 5 1 2 3;
        5 1 2 3 4]; %ordering of conds (A B C ...; B C D ...; etc.)
c = ITEMS(opts(counter,:),:);  %block counterbalancing order


% place in final item order
info = cell(30,11); %init order
for i = 0:4
    info([(1+ i*3):(3 + i*3) (28 - i*3):(30-i*3)],:) = A(c(i+1,:),:);
end
disp(['...item order created for subject ',subj,', run ',num2str(run)])


% load movie names, sound files

stimFiles = [];
for j = 1:30
    if isequal(info{j,8},'audio')
        
        stimFiles(end+1).type = 'audio';
        stimFiles(end).name = info{j,2};
        
        stimFolder
        stimFiles(end).name
        
        
        [y,freq] = audioread([stimFolder stimFiles(end).name]);
        wavedata = y';
        nrchannels = size(wavedata,1);
        pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
        PsychPortAudio('FillBuffer', pahandle, wavedata);
        stimFiles(end).pahandle = pahandle;
    else
        stimFiles(end+1).type = 'movie';
        stimFiles(end).name = info{j,2};
 
            
    end
end

        

% save item order, safe from over-write
fname = ['data/',subj,'_items_run',num2str(run),'.csv'];
x = 1;
while exist(fname)==2
    fname = ['data/',subj,'_items_run',num2str(run),'-x',num2str(x),'.csv'];
    x=x+1;
end

fid = fopen(fname,'w');
fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',raw{1,:});
for i = 1:30
    fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%d\n',info{i,:});
end
fclose('all');
disp(['...item order saved as ',fname])

end

