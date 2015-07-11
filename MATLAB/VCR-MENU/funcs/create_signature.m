function signature = create_signature(data, ExMeth, weighting)
%create_signature - Creates a signature based on the supplied audio samples
%
% Globals : Read/Write - refer to README for global variable descriptions
%   num_feats   : R
%
% Inputs:
%   data - the raw data weight into a signature
%   ExMeth - Extraction method to use, integer corresponding to the list
%   (optional)
%   weighting - list of weights to apply to the data, same length as data
%
% Outputs:
%   signature - Description
%
% References:
%
%
% Authors: David Wernli, Jason Page, Antonia Paris,
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email:
% Website: http://www.
% November 2014; Last revision: 20-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header
global num_feats
if nargin < 3           %if we only got 2 arguments or less as inputs
    weighting = ones(1, length(data));
end

if length(weighting) ~= length(data)
    disp('ERROR creating signature. Weighting and Data arrays must be of equal length');
end

%% Function Body
if ExMeth < 3
    sigMethod = 1;
else
    sigMethod = 2;
end

switch sigMethod
    case 1      %for signatures of fixed lengths
        signature = zeros(1, num_feats);    %initialize the array for the number of features expected
        sum = 0;                            %initialize a sum for the weighting algorit
        for i = 1:length(data)              %go through each data set provided
            tempEx = extract(ExMeth, data{i});      %extract the features
            tempEx = tempEx.value * weighting(i);   %take only the feature vector & weight the result
            if length(signature)==length(tempEx)
                signature = signature + tempEx;         %sum the running total for the signatures
                sum = weighting(i);                     %add the weighting factor for averaging
            end
        end
        signature = signature / sum;         %average the summed feature vectors
        
        
    case 2
        tempEx  = extract(ExMeth, data{1});      %extract the features
        signature = tempEx.value;
end
        %------------- END OF CODE --------------