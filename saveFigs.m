for s = 96:96 %alterar para a quantidade de ratos à serem analisados 
    for sess=1:7 %alterar para qt de sess. à serem analisadas
        close all
        nome = ['rato',num2str(s),'_sess',num2str(sess)];
        D = gonogo('AI0',s,sess); 
        plotGonogo(D); 
        print(['graph/',nome,'_trials'],'-dpng');
        close;
        compareGonogoDistributions('AI0',s,sess);
        print(['graph/',nome,'_distr'],'-dpng');
    end
end
