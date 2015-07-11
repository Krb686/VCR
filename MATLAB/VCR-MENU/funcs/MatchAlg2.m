function Match_Score = MatchAlg2(sig, word)
%% Computes euclidean distance of feature vectors
%% FPGA Version
N = size(sig, 2);
Dif_Temp = 0;
Sum_Temp = 0;

for i = 1:1:N
    Dif_Temp = abs(sig(i) - word(i));
    Sum_Temp = Sum_Temp + Dif_Temp;
end

Match_Score = Sum_Temp;

end