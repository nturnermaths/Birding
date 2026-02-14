%% Audio Analysis - Birding Article
% Birds on Holiday - Mathematics Today, March 2026
% Written in MATLAB 2023b
% Requires audio file input to run:
%   European-Goldfinch-ML181668.wav
clear

% Plot Controls
% STFT Plot
STFTplotOn = 1;
% STFTplotOn = 0;

% Scalogram Plot
SGrmPlotOn = 1;
% SGrmPlotOn = 0;

% Filter Bank
% genFiltBank = 1;
genFiltBank = 0;

% Close all figures if creating new plots
if STFTplotOn == 1 || SGrmPlotOn == 1
    close all
end

tic
% Import data
[audioHS, FsHS] = audioread("European-Goldfinch-ML181668.wav");

% Set maximum time for plotting audio file
lenSetHS = 11;

% Playback data
pbHS = audioplayer(audioHS,FsHS);
% play(pbHS);

% Audio file properties
lenHS = length(audioHS)/FsHS;

%% STFT Processing
% fftLen: 2^7, 2^9, 2^11, 2^13
fftLen = 2^13;
% winLen: 128, 512
winLen = 128;
% Default Window: [ Window=hann(128,"periodic") ]
[sHS, fHS, tHS] = stft(audioHS,FsHS,FFTLength=fftLen,Window=hann(winLen,"periodic"));

% Convert to one-sided spectrum
fHS = fHS(fftLen/2 : end);
sHS = sHS(fftLen/2 : end,:);
% Clip signal output in time & frequency domain
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

%% Plot Spectrogram

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
    title(plotTitle)
    hold off
end

%% Wavelet Processing

% Apply cts wavelet transform to audio using 'amor' (analytic Morlet) and
% sampling frequency FsHS
% Wavelet transform options: 'morse', 'amor', 'bump'
wTr = 'morse';
% vpo: 10, .. 48
vpo = 48;
[wHS, fWav] = cwt(audioHS, wTr, FsHS, VoicesPerOctave=vpo);


%% Plot Scalogram
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

%% Generate and Plot Morse Wavelet example

if genFiltBank == 1

    % Wavelet filterbank for loaded signal
    % Morse [beta,gamma]
    fb = cwtfilterbank('Wavelet', 'Morse', 'SignalLength', 508800, ...
                         'WaveletParameters',[3,60],'VoicesPerOctave',48);
    % Wavelets in time domain for all in filterbank
    [psiWav, tWav] = wavelets(fb);
    
    % Plot selected Morse wavelet from filterbank
    figure('WindowState','maximized','Color','white')
    % Choose wavelet no. to plot (Max = 770)
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

end

toc
