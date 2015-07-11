function features = extract(method, audioData)
%extract Extracts the features from time domain audio data
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
% Globals : Read/Write; refer to README for descriptions
%   Fs              : R
%   num_feats       : R
%   Tw              : R
%   FEATURES        : R
%   signatureObject : R
%
% Inputs:
%   method      = 1:Linear Prediction; 2:LPC Cepstral
%   audioData   = time domain sampled audio data, sampled at global
%                  frequncy Fs
%
% Outputs:
%   features    = featureObject
%
% References:
%   http://www.mathworks.com/help/signal/ref/lpc.html
%   http://www.mathworks.com/help/signal/ref/rceps.html
%   http://www.mathworks.com/help/dsp/examples/lpc-analysis-and-synthesis-of-speech.html
%
%
% Authors: David Wernli, Jason Page, Antonia Paris,
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email:
% Website: http://www.
% September 2014; Last revision: 08-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header

global Fs num_feats Tw FEATURES signatureObject

if FEATURES{method}.enable == 0
    features = [-1];
    return;
end;

%keep the original data for display purposes & debugging
orig_data = audioData;

% remove silence and trim the waveform
audioData = trimAudio(audioData);
if length(audioData) < 10
    audioData = orig_data;
    disp('Trim function could not locate ends. Full sample used');
end

%remove DC component
audioData = audioData - mean(audioData);

%apply pre-emphasis filter
audioData = filter(FEATURES{method}.filter.num, FEATURES{method}.filter.den, audioData);

%normalize filtered signal
audioData = audioData/max(abs(audioData));

switch method
    case 1      %LPC
        %extract Linear Predictive Filter Coefeccients
        [LPC_feat,pow] = lpc(audioData,num_feats-1); % LPC coefficients - see matlab helpfile
        LPC_feat = real(LPC_feat); % extract only the real signal part
        calc_feat = LPC_feat;   %(2:end);
        
        %for n = 1:length(calc_feat)
        %    calc_feat(n) = (1 + (num_feats/2)*sin(pi*n/num_feats))*calc_feat(n);
        %end
        
    case 2      %LPC coef
        %extract Linear Predictive Filter Coefeccients
        [LPC_feat,pow] = lpc(audioData,num_feats-1); % LPC coefficients - see matlab helpfile
        [LPCC_feat,ym] = rceps(LPC_feat); % LPC cepstrum coefs - see matlab helpfile
        calc_feat = LPCC_feat;  %(2:end);
    case 3      %Long LPC
        %get the set of extracted LPCs
        calc_feat = extract_LPCs_Framed(audioData);
    case 4
        
end

%setup the output variable as a signatureObject & return
features = signatureObject;       %format the output to an empty signature object
features.name = FEATURES{method}.name; %insert the features name for later use in text display
features.value = calc_feat;       %save the feature vector into the object
return;
