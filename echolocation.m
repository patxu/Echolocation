function echolocation
    dirName = '..\Audacity\';
    listing = dir(fullfile(dirName, '*.wav')); %get .wav files

    for fileNum = 1:length(listing)
        fileName = strcat(dirName, listing(fileNum).name);
        disp(fileName);
        [y1, Fs] = audioread(fileName);
        % sound(y, Fs);
        y2 = split(y1); %frames
        analyze(y2, listing(fileNum).name);
        return
    end
end

%split vector y1 into frames, storing RMS over the frame, and store in new
%vector y2
function y2 = split(y1)
    frameSize = 5; %size of frame
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
        value = rms(y1(start:stop)) * scaling; %get RMS of frame
        y2(index) = value; %append new RMS value
        start = stop + 1; % new starting index
    end
end

%various analyses
function analyze(y, fileName)
    figure;
    plot(y);
    title(fileName);

    %find the starting index
    startIndex = 0;
    threshold = 15; %start signal threshold
    for index = 1:length(y)
%         disp(index); disp(y(index));
        if y(index) > threshold*mean(y(1:100));
            startIndex = index;
            break
        end
    end
    startIndex = getMax(startIndex, y);

    %find the stopping index
    stopIndex = 0;
    len = length(y);
    threshold = 15; %start signal threshold
    for i = 0:len-1-startIndex
        index = len - i; %TODO
        if y(index) > threshold*mean(y(len-99:len));
            stopIndex = index;
            break
        end
    end
    stopIndex = getMax(stopIndex, y);
    
    peakIndex = getPeak(startIndex, stopIndex, y);
    if peakIndex == 0 %error getting peakIndex
        return
    end
    timePerFrame = 25/(stopIndex-startIndex); %ms/frame
    dist = timePerFrame *(peakIndex-startIndex) * 1.127 / 2;
    output = sprintf('Distance: %.3f ft', dist);
    disp(output);
end

%gets the maximum value from a small window around the startIndex in vector
%y and returns the index
function myIndex = getMax(startIndex, y)
    window = 5;
    max = y(startIndex);
    myIndex = startIndex;
    for index = (startIndex-window):(startIndex+window)
        if y(index) > max
            myIndex = index;
            max = y(index);
        end
    end
end

function myIndex = getPeak(startIndex, stopIndex, y)
    myIndex = 0;
    max = 0;
    buffer = 15; %ignore area near peaks
    for index = (startIndex+buffer):(stopIndex-buffer) 
        if y(index) > max
            myIndex = index;
            max = y(index);
        end
    end
end