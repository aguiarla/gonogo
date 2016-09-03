function D = gonogo(prefix, animalID, session, plotFlag,saveMatFlag)
%function D = gonogo(prefix, animalID, session, plotFlag,saveMatFlag)

% ___________________________________________________________________________________________
% File:             gonogo.m - based on drrd.m
% File type:        Function
% Created on:       September 3, 2016
% Created by:       Marcelo Bussotti Reyes - Universidade Federal do ABC
% Last modified on: 
% Last modified by: 
% Modifications:     
%

%Todo
% Get the nogo delay from data


filename = makeFileName(prefix,animalID,session);

% --- Indexes for each of the output variable columns
dtCol 		= 1;
itiCol		= 2;
reinfCol 	= 3;            % column indicating if the trial was reinforced
typeCol     = 4;            % type of trial (0 = invalid; 1 = go; 2 = nogo
phaseCol	= 5;
sessionCol	= 6;			% session variable column index

dPh			= 0.1;			% initiates the variable just in case it cannot be 
							% obtained from the data, as for example when no 
							% trials were primed (reinforced) in one session

if ~exist('filename','var')
    disp('Missing input variable: name of the file to be analyzed');
end
if ~exist('plotFlag','var')
    plotFlag = true;
end
if ~exist('saveMatFlag','var');
    saveMatFlag = false;
end

% --- removed ---
%if ~exist('isAutoshapeSession','var');  % this var is used for analyzing data
%    isAutoshapeSession = false;         % from autoshape sessions. The difference
%end                                     % lies in the letter A at the end of the filename

if exist(filename,'file');
    data = med2tec(filename); 		% reads data from medpc format to time-event code
elseif exist([filename 'A'],'file');
    data = med2tec([filename 'A']); 		% reads data from medpc format to time-event code
    disp('Found autoshape session');
else
    D = [];
    disp(['File ' filename ' not found']);
    return;
end

% --- Small correction for a bug in the med-pc file ---
if size(data,1)>2               % if the animal presses the lever at the same cycle of the Start command in the
    if data(1,1) > data(2,1)    % box, the first time can be registered wrong, so this sets it to zero as it 
        data(1,1) = 0;          % should be
    end
end

% --- look for indexes of temporal events ---
startIndex      = find(data(:,2)== 1);  
endIndex        = find(data(:,2)== 3);  
startIndex      = startIndex(1:length(endIndex));	% eliminates the last trial in case it was incomplete
%primeIndex      = find(data(:,2)==18); 
failGoIndex     = find(data(:,2)==13);      % detects trials fail go  
succNoGoIndex   = find(data(:,2)==14);      % detects trials success nogo
rLightOnIndex   = find(data(:,2)==12);      % detects when right light was turned on 
hLightOffIndex  = find(data(:,2)==22);      % detects when right light was turned off
hLightOnIndex   = find(data(:,2)==15);      % detects when house light was turned on 
rLightOffIndex  = find(data(:,2)==25);      % detects when house light was turned off

phaseAdvIndex   = find(data(:,2)==17);        % indexes of trials where phase was advanced
phaseBckIndex   = find(data(:,2)==27);        % indexes of trials where phase was retreated


% --- searching for trials in which the animals received food. We call these "primed" ----
%primedTrials	= findTrial(startIndex,primeIndex);
goTrials        = findTrial(startIndex,rLightOnIndex);  % right light means go trials
failGoTrials    = findTrial(startIndex,failGoIndex);
noGoTrials      = findTrial(startIndex,hLightOnIndex);  % house light means nogo trials
succNoGoTrials  = findTrial(startIndex,succNoGoIndex);


% --- searching for trials in which animals progressed or retreated phase
phaseAdvTrials	= findTrial(startIndex,phaseAdvIndex);
phaseBckTrials  = findTrial(startIndex,phaseBckIndex);

% --- searching for trials in which the animals responded with the light on 
% (not in timeout). We'll call these trials "valid". 

% --- checking if the animal responded at all ---
if isempty(startIndex)
    D = [];
    disp('No valid trials, returning D = []');
    return;
end

% --- search for reinforced and non reinforced trials ---
allGoNoGoTrials = [goTrials; noGoTrials];             %this excludes the short trials, the ones that the light was not turned on
failNoGoTrials  = setdiff(noGoTrials,succNoGoTrials);
succGoTrials    = setdiff(goTrials,failGoTrials);
reinfTrials     = [succGoTrials; succNoGoTrials];           % looks for trials when the animals received food and 
invalid			= setdiff(1:length(startIndex), allGoNoGoTrials); % these are the ones shorter than the intial delay
%validNonPrimed 	= setdiff(  validTrials,primedTrials);
%invalid			= setdiff(1:length(startIndex), validTrials);


%--- gets the initial delays from data ---
if length(failGoIndex) >= 1
	delayGo     = data(failGoIndex(1),1) - data(failGoIndex(1)-1,1);
else
	delayGo = 0.5;      % in seconds, delay for go trials
end

delayNoGo = 1;          % in seconds, delay for nogo trials

% --- Organizing data in one single matriz: D --- 
D = zeros(length(startIndex),6);        	% Initiates the vector for speed

% --- Calculating the duration of the lever presses ---
D(:,dtCol)  				= data(endIndex,1) - data(startIndex,1);
D(1:end-1,itiCol) 			= data(startIndex(2:end),1) - data(endIndex(1:end-1),1);
D(end,itiCol) 				= NaN;
D(reinfTrials,reinfCol)     = 1;             % sets to 1 all the trials that were primed
D(goTrials ,typeCol)        = 1;             % sets to 1 all go trials
D(noGoTrials ,typeCol)      = 2;             % sets to 2 all nogo trials
D(phaseAdvTrials,phaseCol)	=  dPh;
D(phaseBckTrials,phaseCol) 	= -dPh;
%D(:,phaseCol) 	= cumsum(D(:,phaseCol))+iniPh;
D(:,sessionCol)		= session;			% puts a mark (1) on the last trial showing that 
									% it was the end of session (eos)
									
% --- graphical part ---
if plotFlag
    hold on;
    plotDrrd(D,filename);
end
%__________________________________________________________________________

% Filtering the responses that were followed by ITI shorter than a
% criterion. The idea behind this is to eliminte responses in which the
% animal did not go look for the pellet, meaning that it was not engaged in
% the task.
%cutoff = 0;             % time in seconds for miminum ITI
%D=D(D(:,2)>cutoff,:);   % eliminates trials in which ITI<cutoff


N  = length(D(:,1));
vp = length(reinfTrials);
vnp= length(invalid);
iv = length(invalid);

fprintf('Rat:%d Session:%d Trials:%d vreinf:%d(%.1f%%) vnreinf:%d(%.1f%%) Inv:%d(%.1f%%)\n',animalID,session,N,vp,vp/N*100,vnp,vnp/N*100,iv,iv/N*100);

% --- saving matlab file in case it was requested ---
if saveMatFlag
    save([filename '.mat'],'D');
end
%__________________________________________________________________________


function ret = findTrial(st, v)
% --- Looks for the trial in which the events occurred
% v is a list of indexes of temporal events. For example, if you know
% that an event ocurred in the index 102, this function will look in the
% indexes of the starts of the trial (st) and count the number of trials
% that had started before that particular event, let's say N, and hence 
% return that the event belongs to that trial N. If v is a vector, the
% function returns all the trials the events belong to

v = v(:);
ret = nan(size(v));
for k = 1:length(v)
    ret(k) = length(st(st<v(k)));
end
%__________________________________________________________________________


function ret = findValidTrial(st,u,v)
% --- Looks for trials that occurred between the events u and v. The most typical
% example is in the drrd trials: only the lever presses that ocurred while the
% light was on are valid. Hence, this function is used to find the trials that
% started after the light was turned on, and before the light was turned off.
% If there were multiple events, e.g. light turns on and off more than once, the 
% junction will look for events that are in between u(i) and v(i) where i is the
% ith time the light was turned on.

u = u(:); v = v(:);				% makes sure the inputs are column vectors
if length(u) ~= length(v)		% makes sure that the events have the same size
	if length(u) == length(v)+1;
		v(end+1) = st(end)+1; 	% just makes the last event one index after the last data set
	else
		disp('Incompatible number of events');
		exit(0);
	end
end

ret = [];               					% initializes the return variable as empty

for k = 1:length(u)							% loop for all the events
    Nu = length(st(st<u(k)));   			% select the starts that happened before the event u(k)     
    Nv = length(st(st<v(k)));        		% select the starts that happened before the event v(k),
    										% supposedly after u(k)    
    ret = vertcat(ret,(Nu+1:Nv)');  		%#ok<AGROW> % adds to the return variable the trials between u(k) and v(k) 
end
%__________________________________________________________________________

function filename = makeFileName(prefix, animalID, session)
% --- Function to put the parts of the file name together ---

animalID = num2str(animalID/1000,'%.4f'); 
animalID = animalID(3:end-1);                 % same with animalID to 3 digits
session  = num2str(session/1000,'%.3f'); 
session  = session(2:end);                  % converts the session to .+3 digits
filename=[prefix animalID session];         % put together the parts 
%_______________________________________________________________________________

