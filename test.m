%Christopher Smith
%Term Project
%
%Test Script

%======================
%Global Variables
%======================

%Amount to segment image into leaf regions, removing the stem
ErodeAmount = 3;
startIndex = 1; %to assist with mid run crashes.

ClassCount = 0;
BufferSize = 4 * ErodeAmount;

%Get all image file names
filesjpg = dir('./data/test/*.jpg');
nfiles = size(filesjpg, 1);


TestList = struct([]);
Region = struct([]);
load('ClassList.mat');

fprintf('# of files: %d\n', nfiles); %print the number of files

%%

%cycle through each image
for n = startIndex:nfiles
    %Get the class of the leaf
    fprintf('%d: %s', n, filesjpg(n).name); %print the image name
    TestList(n).filename = strcat('./data/test/', filesjpg(n).name);
    
    %Load XML File
    xmlpath = strtok(TestList(n).filename, 'jpg');
    xmlpath = strcat(xmlpath, 'xml');
    
    TestList(n).xml = xmlpath;
    TestList(n).class = getClass(xmlpath);
    TestList(n).classGuess = 0;
    fprintf(' - %s\n', TestList(n).class);

    if isempty(ClassList)
        ClassIndex = 0;
    else
        temp = cellstr(char(ClassList(:).name));
        ClassIndex = find(strcmp(TestList(n).class, temp), 1);
    end

    if ~isempty(ClassIndex) && ClassIndex ~= 0
        %If the class is already found
        TestList(n).classIndex = ClassIndex;
    else
        fprintf('New Class Detected in Test Set');
        ClassCount = ClassCount + 1;
        ClassList(ClassCount).name = TestList(n).class; %#ok<SAGROW>
        TestList(n).classIndex = ClassCount;
    end
    
    clear xmlpath ClassIndex temp

    %Load and Segment image
    Base = imread(TestList(n).filename);
    TestList(n).baseWidth = size(Base, 2); %# of cols (Width)
    TestList(n).baseHeight = size(Base, 1); %# of rows (Height)

    Thres = simpleSegment(Base);
    
    Thres = imcomplement(Thres);
    Thres = imclearborder(Thres, 8);

    Thres = bwareaopen(Thres, TestList(n).baseWidth);
    Thres = imfill(Thres, 'holes');
    Thres = bwmorph(Thres, 'erode', ErodeAmount);
    Thres = bwmorph(Thres, 'open', Inf);

    [Region RegCount] = breakImage(Base, Thres, BufferSize, ErodeAmount);
    TestList(n).regionCount = RegCount;

    for r = 1:RegCount

        Region(r).area = bwarea(Region(r).mask);
        Edged = edge(Region(r).mask, 'canny');

        Edged = bwmorph(Edged, 'thin', Inf);
        Edged = bwmorph(Edged, 'spur', Inf);

        Cropped = autoCrop(Edged);
        
        if size(Cropped) ~= 0
            Region(r).croppedArea = size(Cropped, 1) * size(Cropped, 2);
            Region(r).areaRatio = Region(r).area / Region(r).croppedArea;

            Root = [2 find(Cropped(2,:), 1)]; %First Top most pixel
            
            [Chain Found] = traceNeighbors(Cropped, Root(1), Root(2));
            [ProChain] = processChain(Chain);
            RedChain = reduceChain(ProChain);
        else
            RedChain = 0;
        end
        
        TestList(n).chain(r).value = RedChain;
        TestList(n).chain(r).length = size(RedChain, 1);
        
        clear Chain Found ProChain RedChain Root
    end
end

clear filesjpg r n startIndex RegCount ErodeAmount Cropped Edged Base
clear BufferSize Thres

%% Create Trained Data Set

fprintf('Scoring Images\n');

%BestResult = 0;

for n = 1:nfiles
    %Check each region and count up the results for each. The one with the
    %maximum count is the decided winner
    
    Result = zeros([TestList(n).regionCount 1]);
    
    for r = 1:TestList(n).regionCount
        if ~isempty(TestList(n).chain(r).value)
            Result(r) = Score(ClassList, TestList(n).chain(r).value);
        else
            fprintf('\n++Image #%u -- Empty Region Data ', n);
        end
    end
    
    %Count up the most likely class index and choose that as the result
    BestResult = mode(Result(:));
    TestList(n).classGuess = BestResult;
    
    if ~isempty(BestResult) && BestResult > 0
    fprintf('\n--Image #%u : %s; Guess %s ', n, ...
        ClassList(TestList(n).classIndex).name, ClassList(BestResult).name);
    end
end

clear BestResult n r Result
clear n xmlpath filesjpg

%% Blank Fill fields for presentation

for n = 1:nfiles
    if isempty(TestList(n).classGuess)
        TestList(n).classGuess = 0;
    end
end

clear n

%% Output Score

matchTable = OutputResults(TestList, ClassList);