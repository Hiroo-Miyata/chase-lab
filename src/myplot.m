
% for my plot
classdef myplot
    methods (Static)
        function welchplot(signal, fs)
            
            %% Show the power spectrum in 4 ways (takes a bit of time to run)
            figure
            subplot(2,1,1); pwelch(signal,[],[],[],fs); axis([0 1 -inf inf]); title('Welchs, default (8 window)')
            subplot(2,1,2); pwelch(signal,30*fs,[],[],fs); axis([0 1 -inf inf]); title('Welchs, 30s window')

        end
    end
end