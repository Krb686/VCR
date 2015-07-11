Fs = 16000; %sample freq
nBits = 8; %sample bit depth
nChan = 1; %mono/stereo

% Record your voice for 5 seconds.
recObj = audiorecorder(Fs, nBits, nChan);
disp('Start speaking.')
recordblocking(recObj, 1);
    %record(recObj);
    %do something to look at the input stream
    %stop(recObj);
disp('End of Recording.');

% Play back the recording.
play(recObj);

% Store data in double-precision array.
myRecording = getaudiodata(recObj);
% Extract Freq data over 10ms windows
window = 10; %width in ms
samPerWin = round(Fs*window/1000);
for i = 1:samPerWin:length(myRecording)-samPerWin
    start = i;
    ender = i+samPerWin;
    pos = ceil(i/samPerWin);
    x = myRecording(start:ender);
    m = length(x);          % Window length
    n = pow2(nextpow2(m));  % Transform length
    y = fft(x,n);           % DFT
    f = (0:n-1)*(Fs/n);     % Frequency range
    power = y.*conj(y)/n; 
    freqProgression{pos} = y;
    length(freqProgression{pos});
end 
% Plot the waveform.
figure(1);
%subplot(2,1,1);
plot(myRecording);
%subplot(2,1,2);
[S,F,T] = spectrogram(myRecording,128,64,128,Fs,'yaxis')
figure(2)
surf(T,F,abs(S))
view([0 90])
axis tight
xlabel('Time')
ylabel('Frequency')
set(gca,'YScale','log')


