function M = simmx(A,B)
% M = simmx(A,B)
%    calculate a sim matrix between specgram-like feature matrices A and B.
%    size(M) = [size(A,2) size(B,2)]; A and B have same #rows.
% 2003-03-15 dpwe@ee.columbia.edu

% Copyright (c) 2003 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT

EA = sqrt(sum(A.^2));
EB = sqrt(sum(B.^2));

% this is 10x faster
M = (A'*B)./(EA'*EB);