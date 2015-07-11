function [] = mode_MATCH()
%mode_MATCH
%
% Syntax:  [out_status,out_data] = VCR_MAIN()
%
% Inputs:
%   N/A for function call
%   Monitors spacebar for mode switching
%
% Outputs:
%   out_status - 4-digit binary output signaling system status
%   out_data - 8-digit binary output signaling contextual data output
%
% Example: 
%   Line 1 of example
%   Line 2 of example
%   Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
    %
% Design Team: David Wernli, Jason Page, Antonia Paris, Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% September 2014; Last revision: 23-Oct-2014

%------------- BEGIN CODE --------------

Enter your executable matlab commands here

%------------- END OF CODE --------------
%-------------- PSUEDOCODE ---------------
	set sample rate, bit depth
	get input from microphone
	switchcase
	looking mode:
		check for start of word
			change to analyze mode
	analyze mode:
		store most recent input from mic to start of analysis buffer/array
		send the data to the algorithm - algorithm is a class? - has properties of data[string of audio sample datapoints]
		check for end of word
			send end flag to algorithms
			change to looking mode

