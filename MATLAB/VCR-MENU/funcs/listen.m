function utterance = listen(duration);

%%Test Script
  %CONSTANTS AND REF VALUES
    global DEBUG;
    global Fs;
    global nBits;
    global nChan;
    global thresh;          %energy threshold
    NO_HIGH = 4;            %number of consecutive sample windows that must be high to start recording
    NO_LOW  = 64;           %number of low samples to count as end of recording
    MIN_CNT = 1500;         %minimum number of samples allowed to be considered a recording
  %Variable Initialize
    avg = 0;                %average of the current window
    rec_flag = 0;           %currently recording status
    start_counter = 0;      %number of times we've been over the threshold
    end_counter = 0;        %number of times we've been under the threshold
    utterance = 0;          %variable to hold the current utterance

    Microphone = dsp.AudioRecorder('SampleRate', Fs, 'NumChannels', nChan, 'SamplesPerFrame', 16);
        % saves the audio data in 16 sample windows, each sample is 1/8000 of a
        % scond... each window is 16/8000 sec
        % onboard mic-- dsp.AudioRecorder('DeviceName', 'Microphone (Realtek High Definition Audio)')
        % pulgin mic
        

%% PROGRAM START

tic;    %toc is the length in seconds from the last tic call

while (toc < duration) && (rec_flag < 2)         %set up a 10 second timeout timer & exit condition
    audio = step(Microphone);       %get the audio data from the mic
    avg = mean(abs(audio));         %calculate the average of this window
    avg = mean(audio.*audio);   %average energy of the sample
    
    if (rec_flag == 0)               %if we're not yet recording
        if (avg > thresh)           %and the avg is above the thresh        
            if (start_counter < NO_HIGH)      %and we're not yet ready to record
                start_counter = start_counter + 1;                
            else                        %not yet had enough high samples
                rec_flag = 1;           %record those samples!
                tic;                    %and reset the timeout counter
            end %end if
        else      %below threshold
            start_counter = 0;      %reset our start counter
        end %end if
    else    %if rec flag is high (we're recording!
        utterance = [utterance; audio];     %get the data into the array
        if (avg < thresh) || (toc > 0.95)      %%if under threshold or recording > 1 second
            if (end_counter < NO_LOW)
                end_counter = end_counter + 1;
            else
                if length(utterance) > MIN_CNT
                    rec_flag = 2;               %2 signals done, this will exit
                else
                    rec_flag = 0;
                    utterance = 0;
                end
            end %endif low counting
        end     %endif still recording
    end %end if
end

