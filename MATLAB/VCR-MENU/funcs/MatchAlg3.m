function Match_Score = MatchAlg3(sig, word)
%% Computes difference in rate of change for signal vs. rate of change for word
%% FPGA Version
DeltaX = 0;
DeltaY = 0;
DeltaDif = 0;
Delta_Dist = 0;

N = size(sig, 2) - 2;

for i = 1:1:N
    DeltaX = sig(i+2) - sig(i);
    DeltaY = word(i+2) - word(i);
    DeltaDif = abs(DeltaX - DeltaY);
    Delta_Dist = Delta_Dist + DeltaDif;
end

Match_Score = Delta_Dist;

end