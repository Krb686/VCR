function myLPCs = extract_LPCs_Framed( time_Sig )
%getLPCs: returns matrix of LPC coefficients from samples of audio file in time_Sig
%myLPCs is a matrix of LPC coefficients
% applies pre-emphasis filter to audio samples
% splits audio samples into frames
% applies hamming window to frames
% gets LPCs from each frame
% stores LPCs for each frame into a matrix for the whole word

% save sampled signal into temp variable
x = time_Sig;

% ----- LPCs from frames of Word  ----------------------
% Framing of Speech Signal
% see https://sites.google.com/site/ikedija/projects/speech-signal-analysis-with-matlab-2012
% for details. In particular the section under "Requirement: 1. A"
len = length(x); % length of signal
frameLen = 1280; % frame length. Default = 1280 or ceil(len/4)
stepSize = 320; % step size, offset of each frame. Default = 320 or ceil(frameLen/4)
NumOfFrames = ceil(len/stepSize); % number of frames signal is chopped into. function ceil rounds toward next higher integer
% xx is a matrix the size of x + zero padding so we can split it up into an
% whole number of frames.
xx=zeros((NumOfFrames*stepSize+frameLen-stepSize),1);

% Copy x to xx with an initial offset of 120. Buffer added for Hamming
% Windowing of first frame
for i=1:1:len;
    xx(119+i,1)=x(i,1);
end

global num_feats;
collectedLPCs = num_feats; % best results attained at 10 and then 11

% Break xx into windows of 320 samples
N = zeros(frameLen, NumOfFrames); % Matrix to Hold Framed Samples
Nw = zeros(frameLen, NumOfFrames); % Matrix to Hold Windowed Samples
A = zeros(NumOfFrames, (collectedLPCs-1)); % Matrix to Hold LPC coefficients
k = 1; % second variable used for iteration in the below loop

for i=1:stepSize:NumOfFrames*stepSize % repeat this after every step size
    x1=xx(i:i+frameLen-1); % copy a single frame for analysis
    x1w=x1.*hamming(frameLen); % apply Hamming window
    %     figure()
    %     plot(x1)
    %     hold on
    %     plot(x1w, 'r')
    N(:, k) = x1; % save framed samples into matrix N
    Nw(:, k) = x1w; % save windowed, framed samples into matrix Nw
    
    a=lpc(x1w, collectedLPCs); % extract LPC coefficients from windowed, framed sample
    %     a = abs(a);
    %     figure()
    %     stem(20*log10(a))
    A(k, :) = a(2:collectedLPCs); % store coefficients of each frame into matrix of LPC coefficients
    
    k = k+1; % update secondary counter variable
end

myLPCs = A; % return matrix of LPC coefficients

end

