function matchResult = rate_match(method, testSig, refSig)
%FUNCTION_NAME - One line description of what the function or script performs (H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%
% Globals : Read/Write - refer to README for global variable descriptions
%
% Inputs:
%   method      = INT; indicates match method to be used
%                   1: 
%                   2: 
%                   3: 
%                   4: 
%   testSig   = [vector]; the test signature for the current utterance 
%   refSig    = [vector]; the signature to be compared against
%               note: the testSig and refSig must be of the same dimensions
%
% Outputs:
%   matchResult = resultsObject; refer to README for object structure
%
% References:
%
    %
% Authors: David Wernli, Jason Page, Antonia Paris, 
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% November 2014; Last revision: 08-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header
    %Enter optional argument control and persistent variables here
global resultsObject
%% Function Body
%load the template structure for the result
matchResult = resultsObject;
matchResult.method = method;

%shorten in use variables for simpler reading
ref  = refSig.value;
test = testSig.value;

switch method
    case 1      % using covariance ratio of two vectors    
        value = MatchAlg1(ref,test);
    case 2      % using simple euclidean distance sums
        value = MatchAlg2(ref,test);
    case 3      % not yet implemented - correlation
        value = MatchAlg3(ref,test);
    case 4      % not yet implemented
        value = -1;
        %not used
    otherwise
end

%save the obtained value into the return object.
matchResult.value = value;
return;
%------------- END OF CODE --------------