% bank1 = process_signal('N:\252\adultMaleClear.wav');
% bank2 = process_signal('N:\252\adultMaleClear2.wav');
% bank3 = process_signal('N:\252\adultFemaleClear.wav');
% bank4 = process_signal('N:\252\adultFemaleNoise.wav');
% bank5 = process_signal('N:\252\adultMaleNoise.wav');
% bank6 = process_signal('N:\252\adultBothClear.wav');
% bank7 = process_signal('N:\252\adultBothClear2.wav');
% bank8 = process_signal('N:\252\adultBothNoise.wav');
bank9 = process_signal('N:\252\bothBothClear.wav');
% bank10 = process_signal('N:\252\childMaleClear.wav');
% bank11 = process_signal('N:\252\childMaleNoise.wav');
% bank12 = process_signal('N:\252\nonverbalMusic.wav');
% bank13 = process_signal('N:\252\animals.wav');

function f = process_signal(filename)
    %Step 3.1: Read files and find sampling rate    
    [signal,Fs] = audioread(filename);
    info = audioinfo(filename);
    %Step 3.2: convert to mono
    if info.NumChannels == 2
        signal = sum(signal, 2);
    end
    %Step 3.3: Play sound
    %sound(signal, Fs);
    %Step 3.6: Resample to 16 KHz
    if info.SampleRate ~= 16000
        [p,q]=rat(16000/info.SampleRate);
        signal = resample(signal, p, q);
    end
    %Step 3.4: Write sound to new find
    new_name = strcat('new-',erase(filename, "N:\252\"));
%     audiowrite(new_name, signal, 16000);
    info = audioinfo(new_name);
    
    %Step 3.5: Plot  waveform of sound files as function of sample number
%         figure
%         plot(signal);
%         title(new_name);
%         xlabel('Sample Number');
%         ylabel('Signal');
% 
%         figure
%         fm = 1000;
%         d = info.Duration/info.TotalSamples;
%         x = 0: d :info.Duration;
    %Step 3.7: Generate cosine function
%         whole_cos = cos(2*pi*fm*x);
%         t = 0: d :0.002;
%         y =cos(2*pi*fm*t);
%         sound(whole_cos, 16000);
%         %plot(t,y);
%         new_title = strcat(new_name, ' - 2 Cycles Cosine Signal');
%         title(new_title);
%         xlabel('time (s)');
%         ylabel('Output Signal');

    %Step 4: Designed bank of passband filters
    passband_bank = zeros(length(signal), 16);
    
    number_channels = 16;
    lower_cutoffs = [100, 220, 320, 420, 520, 620, 720, 820, 920, 1020, 1520, ...
        2020, 2520, 3520, 5020, 6520];
    upper_cutoffs = [180, 280, 380, 480, 580, 680, 780, 880, 980, 1480, 1980, ...
        2480, 3480, 4980, 6480, 7975];

    %Step 5: Filter sound with passband bank
    for i=1:number_channels
        filter_function = butter(lower_cutoffs(i), upper_cutoffs(i));
        passband_bank(:, i) = filter(filter_function, signal);
    end
    
    %Step 6: Plot output signals of lowest and highest frequency channels
%     figure
%     plot(kaiser_bank(:, 1));
%     title("Lowest Frequency Channel");
%     xlabel('Sample Number');
%     ylabel('Signal');
%     
%     figure
%     plot(kaiser_bank(:, 16));
%     title("Highest Frequency Channel");
%     xlabel('Sample Number');
%     ylabel('Signal');
    
    
    % Step 7: Envelop extraction step 1: Rectify the output signal of all
    % bandpass filters
    [rows, cols] = size(passband_bank);
    rectified_channels = abs(passband_bank); 
    envelopes = zeros(length(signal), number_channels);    
  
%     Step 8: Envelop extraction step 2: Detect envelopes of all rectified
%     signals usig lowpass filter with 400 Hz cutoff
    for i=1:cols
        envelopes(:, i) = filter(envelope, rectified_channels(:, i));
    end
    
%     Step 9: Plot envelope of lowest and highest frequency channels
    
%     figure
%     plot(envelopes(:, 1));
%     title("Envelope Lowest Frequency Channel");
%     xlabel('Sample Number');
%     ylabel('Signal');
%     
%     figure
%     plot(envelopes(:, 16));
%     title("Envelope Highest Frequency Channel");
%     xlabel('Sample Number');
%     ylabel('Signal');

    %Step 10: Cosine signal
    cosine_signals = zeros(length(signal), number_channels);
    center_f = zeros(number_channels, 1);

    d = info.Duration/info.TotalSamples;
    x = 0: d :info.Duration - d;
    for i=1:number_channels
        center_f(i) = sqrt(lower_cutoffs(i) * upper_cutoffs(i)); 
        cosine_signals(:,i) = cos(2*pi*center_f(i)*x);
    end
    
    %Step 11: Amplitude modulation
    for i=1:number_channels
       signals = cosine_signals.*envelopes; 
    end
    
    %Step 12: Add up into output signal
    output = zeros(length(signal), 1);
    for i=1:number_channels
       output = output + signals(:, i);
    end
    
    %Step 13: Play output sound
    sound(output, 16000);
    new_name = strcat('Butterworth-output-', erase(filename, "N:\252\"));
    audiowrite(new_name, output, 16000);
    
    
    %Checking runtime of different filters...
%     kaiser_func = @()window(100, 200);
%     butter_func = @()butter(100, 200);
%     cheb_func = @()cheb(100, 200);
% 
%     kaiser_time = timeit(kaiser_func)
%     butter_time = timeit(butter_func)
%     cheb_time = timeit(cheb_func)


    %Finding RMSE:
%     error = (signal - output).^2;
%     RMSE = sqrt(sum(error)/length(signal))

    f = passband_bank;
end


function Hd = window(fc1, fc2)
% Returns a discrete-time filter object.
% All frequency values are in Hz.
Fs = 16000;  % Sampling Frequency

N    = 50;       % Order
Fc1  = fc1;      % First Cutoff Frequency
Fc2  = fc2;      % Second Cutoff Frequency
flag = 'scale';  % Sampling Flag
Beta = 0.5;      % Window Parameter

win = kaiser(N+1, Beta);
b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);
Hd = dfilt.dffir(b);
end

function Hd = butter(fc1, fc2)
%Returns a discrete-time filter object.
% Butterworth Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.
Fs = 16000;  % Sampling Frequency

N   = 14;   % Order
Fc1 = fc1;  % First Cutoff Frequency
Fc2 = fc2;  % Second Cutoff Frequency

h  = fdesign.bandpass('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');
end

function Hd = cheb(fc1, fc2)
% Returns a discrete-time filter object.
% All frequency values are in Hz.
Fs = 16000;  % Sampling Frequency

N      = 14;   % Order
Fpass1 = fc1;  % First Passband Frequency
Fpass2 = fc2;  % Second Passband Frequency
Apass  = 1;    % Passband Ripple (dB)

h  = fdesign.bandpass('N,Fp1,Fp2,Ap', N, Fpass1, Fpass2, Apass, Fs);
Hd = design(h, 'cheby1');
end

function Hd = envelope
% Returns a discrete-time filter object.
% All frequency values are in Hz.
Fs = 16000;  % Sampling Frequency

N    = 50;       % Order
Fc   = 500;      % Cutoff Frequency
flag = 'scale';  % Sampling Flag
Beta = 0.5;      % Window Parameter

win = kaiser(N+1, Beta);
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dfilt.dffir(b);
end



