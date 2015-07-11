function speechFlag = startFinder(sample ,threshold, cutoff)
%startFinder Figures whether the speech signal has started, sets a flag
%funciton will return a '1' if the signal is over the minumum power
%threshold and will return a '0' otherwise
%
% Globals:
%   thresh      : minimum power threshold for signal ID
%
% Inputs:
%       (requried)
%   sample      - the sampled audio signal input
%      (optional)
%   threshold   - the minimum threshold required to be classified 'speech'
%   cutoff      - the number of previous samples that must be zero for the
%                   function to declare no more speech is heard. Meant to
%                   delay the flagging of momentary pauses
%   
%
% Outputs:
%   speechFlag  - a simple status flag indicating if speech is detected
%
% References: 
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
global thresh;
persistent lastFlag;

if nargin < 3           %if we only got 2 arguments or less as inputs
    cutoff = 10;
end
if nargin < 2           %if we only got 1 argument as input
    threshold = thresh;
end

%% Function Body
speechFlag = 0;
instantPwr = abs(sample^2);
if(instantPwr > threshold)
    lastFlag = 0;
else
    lastFlag = lastFlag +1;
end;

if(lastFlag < cutoff)
    speechFlag = 1;
end

%------------- END OF CODE --------------