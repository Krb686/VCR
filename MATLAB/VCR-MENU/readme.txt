README.txt

Global Variable Descriptions
    cmd_list    : list of command word objects - see wordObject structure below
    Fs          : sample frequency for audioData in Hz
    num_feats   : number of features to extract with LPC
    Tw          : window size for feature extraction
    FEATURES    : holds the name of the in-use feature extraction methods
                 used for tagging and text output to user
    signatureObject : placeholder object for holding returned signatures
                      see below for structure
    dur         : recorded sample duration in seconds
    FEATURES    : holds the name of the in-use feature extraction methods
                  used for tagging and text output to user


%       features.name               = string of the type of extraction used
%               .value              = array of the coeficients
%               .signature       {} = signature object (corresponding to utterance under test)
%               .results         {} = matchResult objects
%
%               matchResult Object  = MR
%                     MR.method     = INT corresponding to method{n}.name
%                            METHOD = {'k-nearest' 'euclidean' 
%                                      'correlation' 'mahalanobis'}
%                     MR.value      = decimal value corresponding to above
%                                     methods; 0 < value < 1


DataFlow:
MAIN.GUI -------+-----------------+-----------------+
                |                 |                 |
            TUNING.GUI       TESTING.GUI       TRAINING.GUI

    TRAINING.GUI