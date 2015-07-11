function initialize()
%% Specific to this instance of constant listening
    global DEBUG nChan Fs nBits thresh PLOT
    DEBUG = 1;
    nChan = 1;
    Fs = 8000;
    nBits = 8;
    thresh = 0.05;           %energy threshold
    PLOT = 0;