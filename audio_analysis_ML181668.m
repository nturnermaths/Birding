%% Audio Analysis - Birding Article
clear

% Plot Controls
% STFT Plot
STFTplotOn = 1;
% STFTplotOn = 0;

% Scalogram Plot
SGrmPlotOn = 1;
% SGrmPlotOn = 0;

% Close all figures if creating new plots
if STFTplotOn == 1 || SGrmPlotOn == 1
    close all
end

tic
% Import data
[audioHS, FsHS] = audioread("European-Goldfinch-ML181668.wav");

% Set maximum time for plotting audio file
lenSetHS = 11;
% audioHS = audioHS(1:lenSetHS*FsHS);

% Re-save the clipped audio file
% audiowrite("European-Goldfinch-June2025-Clipped.wav",audioHS,FsHS);

% Playback data
pbHS = audioplayer(audioHS,FsHS);
% play(pbHS);

% Audio file properties
lenHS = length(audioHS)/FsHS;

% Compute STFT of signal
fftLen = 2^7;
winLen = 128;
[sHS, fHS, tHS] = stft(audioHS,FsHS,FFTLength=fftLen,Window=hann(winLen,"periodic"));
% Default = [ Window=hann(128,"periodic") ]
% Convert to one-sided spectrum
fHS = fHS(fftLen/2 : end);
sHS = sHS(fftLen/2 : end,:);
% Curtail signal in time & frequency domain
fMax = 10e3;
tMax = lenSetHS;
tHS = tHS(tHS < tMax);
fHS = fHS(fHS < fMax);
sHS = sHS(fHS < fMax,tHS < tMax);

% Set dB reference and convert to dB
% dBref = 20e-6;
% sHSmag = mag2db(abs(sHS/dBref));

% Find abs value for plotting amplitude
sHSmag = abs(sHS);

%% Plot Original Recording Data

if STFTplotOn == 1
    % Plot data on spectrogram
    figure('WindowState','maximized','Color','white')
    meshHS = mesh(tHS,fHS,sHSmag);
    hold on
    pbaspect([2 1 1]);
    % Plot up to 10 kHz
    plotFmax = 10e3;
    plotTmax = tMax;
    xlim([0 plotTmax])
    ylim([0 plotFmax])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    zlabel('Magnitude')
    view(2)
    cb = colorbar;
    ylabel(cb,'Amplitude')
    %  clim([20 100]) % dB re 20 uPa
    clim([0 0.5]) % linear
    fontsize(gca,30,"points")
    plotTitle = "Goldfinch Spectrogram; L = " + num2str(fftLen) + "; " + "L_{win}" + " = " + ...
                   num2str(winLen);
    % title(plotTitle)
    hold off
end

%% Wavelet Processing

% Apply cts wavelet transform to audio using 'amor' (analytic Morlet) and
% sampling frequency FsHS
% Wavelet transform options: 'morse', 'amor', 'bump'
wTr = 'morse';
vpo = 48;
[wHS, fWav] = cwt(audioHS, wTr, FsHS, VoicesPerOctave=vpo);

if SGrmPlotOn == 1
    figure('WindowState','maximized','Color','white')
    cwt(audioHS, wTr, FsHS, VoicesPerOctave=vpo);
    xlim([0 11])
    ylim([1 10])
    clim([0 0.01])
    plotTitle = "Goldfinch Scalogram; Morse, Voices per Octave = " + ...
                    num2str(vpo);
    % title(plotTitle)
    yticks(1:10)
    yticklabels(1000*(1:10))
    ylabel('Frequency (Hz)')
    xticks(0:11)
    xticklabels(0:11)
    xlabel('Time (s)')
    fontsize(gca,30,"points")

end

% Convert cwt output to dB
% wHSmag = mag2db(abs(wHS/dBref));

% Find abs value for amplitude
wHSmag = abs(wHS);

%% Generate and plot Morse wavelet example

fb = cwtfilterbank('Wavelet', 'Morse', 'SignalLength', 508800, ...
                     'WaveletParameters',[3,60],'VoicesPerOctave',48);
[psiWav, tWav] = wavelets(fb);
figure('WindowState','maximized','Color','white')
% Choose wavelet no. to plot
indWav = 700;
realWav = real(psiWav(indWav,:));
imagWav = imag(psiWav(indWav,:));
magWav = sqrt(realWav.^2 + imagWav.^2);
maxAmp = magWav(length(magWav)/2);
plot(tWav, realWav, 'r', 'LineWidth', 2)
hold on
plot(tWav, imagWav, 'b', 'LineWidth', 2)
plot(tWav, magWav, 'k', 'LineWidth', 2);
scatter(0,maxAmp,100,'black','filled');
text(100,maxAmp+3e-5,'Pk_{60,3}','FontSize',20)
% title('Morse (3,60) Wavelet in the Time Domain: s = 700, v = 48');
legend('Real Part', 'Imaginary Part','Magnitude');
xlabel('Time Sample Index')
ylabel('Magnitude')
% ylim([-8e-4 8e-4])
fontsize(gca,30,"points")

%% Backup: Bandpass Filter Example

% %% Apply Band Pass Filter
% % Apply band pass filter
% % Filter out collared dove < 750 Hz
% fPass = [2000 10000];
% audioHS = bandpass(audioHS,fPass,FsHS);
% 
% % Playback data
% pbHSbp = audioplayer(audioHS,FsHS);
% % play(pbHSbp);
% 
% % Compute STFT of signal
% [sHS, fHS, tHS] = stft(audioHS,FsHS,FFTLength=fftLen);
% % Convert to one-sided spectrum
% fHS = fHS(fftLen/2 : end);
% sHS = sHS(fftLen/2 : end,:);
% % Curtail signal in time & frequency domain
% tHS = tHS(tHS < tMax);
% fHS = fHS(fHS < fMax);
% sHS = sHS(fHS < fMax,tHS < tMax);
% 
% % Set dB reference and convert to dB
% sHSmag = mag2db(abs(sHS/dBref));
% 
% % Re-save the bandpassed audio file
% audiowrite("European-Goldfinch-ML181668-Bandpass.wav",audioHS,FsHS);


% %% Plot Bandpass Data
% 
% if plotOn == 1
%     % Plot data on spectrogram
%     figure('WindowState','maximized')
%     meshHS = mesh(tHS,fHS,sHSmag);
%     hold on
%     pbaspect([2 1 1]);
%     % Plot up to 10 kHz
%     plotFmax = 10e3;
%     plotTmax = tMax;
%     xlim([0 plotTmax])
%     ylim([0 plotFmax])
%     xlabel('Time (s)')
%     ylabel('Frequency (Hz)')
%     zlabel('Amplitude (dB)')
%     view(2)
%     colorbar
%     clim([20 100])
%     hold off
% end

toc
