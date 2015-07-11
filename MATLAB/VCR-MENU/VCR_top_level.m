%%
% UART for FPGA shows up as COM5 on Dave's Surface, 
% Microphone is audio device 0

%instrfind
delete(instrfindall); 
nexys = serial('COM5', 'BaudRate', 9600);
fopen(nexys);
nexys.Terminator = '';
fprintf(nexys, 255);

%% Program operation
%Local Variables
word_no = 0;        %when == 0 tests all words
speaker_no = 0;     %when == 0 tests all speakers
global DEBUG Fs nBits score guess;
audioData = 0;

%initialize the folders and data necessary
initialize();

tic;
while (toc < 10)
    audioData = listen(10);
    if (length(audioData) > 1)
        %disp('    audio recorded');
        toc;         %report current time at end of capture
        test_single(audioData)
        
        fprintf( nexys, 0 );
        fprintf( nexys, guess(1) );
        
        toc;         %report length of time elapsed in processing
        tic;
    else
        disp('    no audio detected');
    end
    
    % POST COMPLETION DEBUG
    if (DEBUG == 1)
        %play the audio back - debugging only
        disp('    ---playing recorded sound');
        player = audioplayer(audioData,Fs,nBits);
        play(player);
    end %end debug chunk
end

% Disconnect from instrument object, obj1.
fclose(nexys);

% Clean up all objects.
delete(nexys);