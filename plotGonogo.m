function ret = plotGonogo(D, sortFlag, title_label)
%function ret = plotGonogo(D, sortFlag, title_label)
%function ret = plot(D, title_label)
% Each line of the matrix D is a trial
% Column 1 is the duration of the lever press
% Column 2 is the the time between the lever release and the next lever press (ITI)
% Column 3 is 1 for the reinforced trials
% Column 4 is 0 for invalid trials, 1 for  go trials, and 2 for nogo trials
% Column 5 is not used
% Column 6 is the session number

% Usage: close all; D = gonogo('AI0',96,5, 1,0); plotGonogo(D);



% --- parameter check ---
if ~exist('title_label','var'); title_label = []; end
if ~exist('sortFlag','var'); sortFlag = true; end

if sortFlag
    if ~isempty(D)
        D = sortrows(D,4);
    else
        ret = 1;
        disp('Matriz de dados vazia');
        return;
    end
end
% --- 

% --- data-related constants ---
reinf  = 3;		% column showing reiforced trials
type   = 4;     % column with the trial type (0:invalid, 1:go, 2:nogo)
session = 6; 	% column with the session number

typeGo      = 1;    % defines the code for go type of trials
typeNogo    = 2;    % defines the code for nogo type of trials
typeInvalid = 0;    % defines the code for invalid type of trials

N = size(D,1);      % total number of trials

% --- looking for the specific trials ---
%validPrimed 	= find(D(:,primed)==1 	& D(:,valid)==1);
reinfGoTrials       = find(D(:,reinf)==1 	& D(:,type) ==   typeGo);    % reinforced go trials 
nonReinfGoTrials 	= find(D(:,reinf)==0 	& D(:,type) ==   typeGo);    % non reinforced go trials
reinfNoGoTrials     = find(D(:,reinf)==1 	& D(:,type) == typeNogo);    
nonReinfNoGoTrials  = find(D(:,reinf)==0 	& D(:,type) == typeNogo);    
invalid             = find(D(:, type)==typeInvalid);

clf; hold on;

% --- plotting the prime times ---
%plot(D(:,primeT),1:N,'r','linewidth', 1.5);

% --- alternative: patch ---
%patch([ D(:,5); 0.01; 0.001], [1:N N 1], [.7 .8 .7] ,'EdgeColor' ,'none');% % [.7 .8 .7]
%patch([ D(:,5); 0.02; 0.02], [1:N N 1], [.7 .5 .2] ,'EdgeColor' ,'none');% % [.7 .8 .7]
%patch([ 0.5   ; 0.02; 0.02], [1:N N 1], [.7 .5 .2] ,'EdgeColor' ,'none');% % [.7 .8 .7]

% --- Plotting the moving average of the lever press durations ---
%plot(movingAverage(D(:,1),20),1:N,'linewidth',2);

% --- Plotting each trial in a different style ---
%plot(D(validPrimed,1)   ,validPrimed,   'ko','markersize',4, 'markerfacecolor','k');
plot(D(reinfGoTrials,1)     ,reinfGoTrials,     'ko','markersize',4, 'markerfacecolor','k');
plot(D(nonReinfGoTrials,1)  ,nonReinfGoTrials,  'ko','markersize',4, 'markerfacecolor','w');
plot(D(reinfNoGoTrials,1)   ,reinfNoGoTrials,   'mo','markersize',4, 'markerfacecolor','m');
plot(D(nonReinfNoGoTrials,1),nonReinfNoGoTrials,'mo','markersize',4, 'markerfacecolor','w');

%plot(D(validNonPrimed,1),validNonPrimed,'ko','markersize',5, 'markerfacecolor','w','linewidth',1);
plot(D(invalid,1)		,invalid,		'r.','markersize',10);

% --- setting up the scale and title ---
%if D(end,5)>1                       % checks if there was a positive creterion
%    xlim([0 2*D(end,5)]);           % if so, adjusts x scale to be proportional to it
%else
%    xlim([0 4]);                    % otherwise keeps the x scale "basic"
%end
    
xlabel('Tempo (s)','fontsize',16);
if sortFlag
    ylim([0 N+5]);          ylabel('Tentativa (fora de ordem)','fontsize',16);
else
    ylim([0 N+5]);          ylabel('Tentativa','fontsize',16);
end
title(title_label,'fontsize',14);
set(gca,'box','on','fontsize',12);
legend({'reinfGo','nonReinfGo','reinfNoGo','nonReinfNoGo','invalid'});


% --- printing the lines dividing the sessions ---
div = find(diff(D(:,session)));
for k = 1:length(div)
	plot(xlim,[div(k) div(k)],'k--');
end

% --- mounting return variable ---
ret = [length(reinfGoTrials)/N length(nonReinfGoTrials)/N length(reinfNoGoTrials)/N length(nonReinfNoGoTrials)/N length(invalid)/N] *100;
disp(ret);
