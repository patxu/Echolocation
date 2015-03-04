function echolocation

dirName = '..\Audacity\';
listing = dir(fullfile(dirName, '*.wav')); %get .wav files

for fileNum = 1:length(listing)
    fileName = strcat(dirName, listing(fileNum).name);
    disp(fileName);
    [y1, Fs] = audioread(fileName);
    % sound(y, Fs);
    
    frameSize = 10; %size of frame
    last = ceil(length(y1)/frameSize);
    start = 1;
    y2 = zeros([last,1]); %initialize the output array
    
    for index = 1:last
        stop = frameSize * index - 1; %index of last element of the frame
        scaling = 1;
        if index == last %don't exceed end of matrix
            stop = length(y1);
            scaling = (stop-start)/frameSize; %correctly scale RMS for shortened frame
        end
        value = rms(y1(start:stop)) * scaling;
        y2(index) = value; %append new RMS value
        start = stop + 1; % new starting point
    end
    analyze(y2);
    return
end

function analyze(y)
figure;
plot(y);

%find the start index
startIndex = 0;
threshold = 5; %start signal threshold
for index = 1:length(y)
%     disp(index); disp(y(index));
    if y(index) > threshold*mean(y(1:100));
        startIndex = index;
%         break
    end
end

%find the stop index
stopIndex = 0;
len = length(y);
threshold = 5; %start signal threshold
for i = 0:len-1
    index = len - i;
    if y(index) > threshold*mean(y(len-99:len));
        stopIndex = index;
        break
    end
end