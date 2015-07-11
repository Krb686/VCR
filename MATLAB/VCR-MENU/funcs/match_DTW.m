function pathDist = match_DTW( matrix1, matrix2 )
%dtwLPC: Function to compute shortest path between two time varying
%matrices of sequences of LPCs extracted from a spoken utterance
% most code found on http://www.ee.columbia.edu/~dpwe/resources/matlab/dtw/
% 2003-03-15 dpwe@ee.columbia.edu
% Copyright (c) 2003 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT

matrix1T = matrix1.';  % Invert matrix.  Rows of matrices must be the same.
matrix2T = matrix2.';  % Invert matrix.  Rows of matrices must be the same.

% Construct the 'local match' scores matrix
SM = simmx(abs(matrix1T),abs(matrix2T));

% % Plot local match scores matrix
% figure()
% subplot(121)
% imagesc(SM)
% colormap(1-gray)
% You can see a dark stripe (high similarity values) approximately down the leading diagonal.

% Use dynamic programming to find the lowest-cost path between the opposite corners of the cost matrix
% Note that we use 1-SM because dp will find the *lowest* total cost
[p,q,C] = dp(1-SM);

% % Overlay the path on the local similarity matrix
% hold on; plot(q,p,'r'); hold off
% % Path visibly follows the dark stripe
% 
% % Plot the minimum-cost-to-this point matrix too
% subplot(122)
% imagesc(C)
% hold on; plot(q,p,'r'); hold off

% Bottom right corner of C gives cost of minimum-cost alignment of the two
% This is the value we would compare between different templates if we were doing classification.
pathDist = C(size(C,1),size(C,2));

end

