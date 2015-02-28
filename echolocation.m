function echolocation
global Fs;
global rec;
global audio;

%create tone
F1 = 5000; %tone frequency
Fs = 44100; %sampling frequency
play_duration = 1000; %play duraction in ms
t = 0:Fs*play_duration/1000';
s1 = cos(2*pi*F1*t/Fs); %create waveform

audio = audioplayer(s1, Fs);

%create audio recorder: 44100 Hz, 16 bits, mono, default channel
rec = audiorecorder(Fs, 16, 1);
delay = setup;

% Determine the delay in the system with a test tone
function [delay] = setup
global Fs;
global rec;
global audio;
% play(audio);

%get the silence threshold over 1 second
disp('Generating silence threshold');
rec_duration = 2000; %record duration in ms
recordblocking(rec, rec_duration/1000);
data = getaudiodata(rec); %get data
threshold = max(data)*1.5; %set threshold, 1.5 multiplier is arbitrary
disp(['Threshold is: ' num2str(threshold)]);

%get system delay
disp('Calculating the system delay');
% play(audio);
rec.StartFcn = 'play(audio);';
% rec.StopFcn = 'data = getaudiodata(rec);';
recordblocking(rec, rec_duration/1000);
data = getaudiodata(rec);

for index = 1:Fs*rec_duration/1000;
%     threshold = 0;
    if abs(data(index,1)) < threshold %check threshold value on col 1
        data(index,1) = 0;
    end
end
figure(1);
plot(data);

delay = 1;
