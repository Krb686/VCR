function Match_Score = MatchAlg1(sig, word)
%% Computes modified version of Variance and Covariance and Difference
%% FPGA Version
sum_Sig = sum(sig);
sum_Word = sum(word);
mean_Sig = sum_Sig/32;
mean_Word = sum_Word/32;

Var_Sig =  0;
Var_Word = 0;
Cov_Sig_Word = 0;
N = size(sig, 2);

for i = 1:1:N
    Var_Sig = ((sig(i)- mean_Sig)^2) + Var_Sig;
    Var_Word = ((word(i)- mean_Word)^2) + Var_Word;
    Cov_Sig_Word = ((sig(i)-mean_Sig)*(word(i)-mean_Word)) + Cov_Sig_Word;
end

Var_Sig = Var_Sig - Cov_Sig_Word;
Var_Word = Var_Word - Cov_Sig_Word;

Var_Sig = abs(Var_Sig);
Var_Word = abs(Var_Word);

Match_Score = Var_Sig + Var_Word;