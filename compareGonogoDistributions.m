function peak = compareGonogoDistributions(prefix,animalID,sessions)
%function peak = compareGonogoDistributions(prefix,animalID,sessions)
% ___________________________________________________________________________________________
% File:             compareGonogoDistributions.m
% Based on          compareSessionsDistributions.m
% File type:        Function
% Created on:       September 3 2016
% Created by:       Marcelo Bussotti Reyes
% Last modified on: 
% Last modified by: 
% Modifications:     
%
%	
% Purpose:          A function that analyzes the performance of rats in the gonogo
%                   procedure 
%
% Input:            File name prefix as a string, animal id as a number and 
%					          session as an array (e.g 1:5 analyzes sessions one through
%                   5. Filene name are in the format: [PPPAAA.SSSA] where PPP
%                   is the prefix label (experiment id) AAA is the animal number
%                   and SSS is the session to be analyzed. A is an optional
%                   label that identifies the Autoshape sessions.
%
% Output:           peak, array containing the peak times for each session
%
% Coments:          Uses functions: gonogo.m, med2tec.m, plotGonogo.m (all 
%                   though gonogo.m),
%                   
%
% Format:           peak =compareGonogoDistributions(prefix,animalID,sessions,isAutoshapeSession)
% Examples: 
%                   peak = compareGonogoDistributions('AI0',91,5);
%                       runs analysis for experiment AI0, animal 91,
%                       sessions 5


% Todo: fix the plot using the dt/2: replace the histc by hist (check
% documentation.

% obsolete
%if ~exist('isAutoshapeSession','var')
%    isAutoshapeSession = false;         % defaulte is the drrd session, not autoshape
%end

% --- constants related to data structure ---
typeCol = 4;


close all;

dt    = 0.02;            % delta T for histogram calculation 0.02
rng   = 0:dt:3;          % range of times for binning histogram
sigma = 0.05;             % standard deviation for the gaussian for smoothing (0.2 for Diegos thesis)

lnClr = {'k' 'r' 'm' 'g' 'c' 'y' [.3 .3 .3] [.4 .4 .4] [.5 .5 .5] [.6 .6 .6] [.7 .7 .7] [.8 .8 .8]};
maxClr = 12; 

gauss = dt/sqrt(2*pi())/sigma*exp(-0.5*((rng-mean(rng))/sigma).^2);

count = 1;
hc = rng(:);

for k = sessions
    D = gonogo(prefix,animalID,k,false,false);
    
    n = histc(D(:,1),rng);
    n = n/length(D(:,1))/dt;

    thisInd = find(D(:,typeCol)==1);          % go trials are type 1
    nGo = histc(D(thisInd,1),rng);
    nGo = nGo/length(D(thisInd,1))/dt;
    
    thisInd = find(D(:,typeCol)==2);          % go trials are type 2
    nNoGo = histc(D(thisInd,1),rng);
    nNoGo = nNoGo/length(D(thisInd,1))/dt;

    thisInd = find(D(:,typeCol)==0);          % invalid trials
    nInv = histc(D(thisInd,1),rng);
    nInv = nInv/length(D(thisInd,1))/dt;
    
    %stairs(rng,n,'-','color',lnClr{clrCount},'linewidth',2) ; hold on;
    
    hc    (:,count) = n(:);         % gets the histogram counts (hc) in a columnn vector
    hcGo  (:,count) = nGo(:);  
    hcNoGo(:,count) = nNoGo(:);
    hcInv (:,count) = nInv(:);
    
    C     = conv(n    ,gauss,'same');   % convolves the histogram counts with a gaussian for smoothig
    CGo   = conv(nGo  ,gauss,'same');
    CNoGo = conv(nNoGo,gauss,'same');
    CInv  = conv(nInv ,gauss,'same');
    
    hold on;
    
    disp(mod(count,maxClr));
    plot(rng+(dt/2),C,'-','markerfacecolor','w',...    % plots the smooth function
        'color',lnClr{mod(count-1,maxClr)+1},...
        'linewidth',3,'markersize',5);
    lgnd{count} = ['all-sess.' num2str(k,'%g')];
    
    count = count +1;
    plot(rng+(dt/2),CGo,'-','markerfacecolor','w',...    % plots the smooth function
        'color',lnClr{mod(count-1,maxClr)+1},...
        'linewidth',3,'markersize',5);
    lgnd{count} = ['go-sess.' num2str(k,'%g')];
    
    count = count +1;
    plot(rng+(dt/2),CNoGo,'-','markerfacecolor','w',...    % plots the smooth function
        'color',lnClr{mod(count-1,maxClr)+1},...
        'linewidth',3,'markersize',5);
    lgnd{count} = ['nogo-sess.' num2str(k,'%g')];
    
    count = count +1;
    plot(rng+(dt/2),CInv,'-','markerfacecolor','w',...    % plots the smooth function
        'color',lnClr{mod(count-1,maxClr)+1},...
        'linewidth',3,'markersize',5);
    lgnd{count} = ['inv-sess.' num2str(k,'%g')];
    
    ind = find(C == max(C),1,'last');
    peak(count,:) = [rng(ind) + dt/2 C(ind)];
    disp(peak);
    
    count = count+1;   
end

legend(lgnd,'location','NE');
xlim([min(rng) max(rng)]);
set(gca, 'box','on');
xlabel('time (s)','fontsize',18,'fontname','arial');
ylabel('P[time]'    ,'fontsize',18,'fontname','arial');
set(gca,'fontsize',16);

%% plotting the peak positions
%for k = 1:count-1
%    plot(peak(k,1),peak(k,2),'o-','markerfacecolor','w',...
%        'color',lnClr{mod(k-1,maxClr)+1},'linewidth',2);
%end

%figure; 
%plot(hc-C);
%disp(mean(hc-C));
%disp(mean(hc-C).^2);


%figure; hold on;
%plot(sessions,peak(:,1));

