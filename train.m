%Christopher Smith
%Term Project
%
%Training Script

%======================
%Global Variables
%======================

%Amount to segment image into leaf regions, removing the stem
ErodeAmount = 3;
startIndex = 1; %to assist with mid run crashes.

ClassCount = 0;
BufferSize = 4 * ErodeAmount;

%Get all image file names
filesjpg = dir('./data/train/*.jpg');
nfiles = size(filesjpg, 1);

%What information is needed to track?
%-The image itself isn't needed beyond processing
%-I need to track the data points, all of them. I can reduce later
%-I need to track the variance as well as the simple vectors
%-For the time being as a proof of concept, I need to be able to look at
%each step.
%-I need to track the class of the object

ObjectList = struct([]);
Region = struct([]); %#ok<NASGU>
ClassList = struct([]);

fprintf('# of files: %d\n', nfiles); %print the number of files

%%

%cycle through each image
for n = startIndex:nfiles
    %Get the class of the leaf
    fprintf('%d: %s', n, filesjpg(n).name); %print the image name
    ObjectList(n).filename = strcat('./data/train/', filesjpg(n).name);
    
    %Load XML File
    xmlpath = strtok(ObjectList(n).filename, 'jpg');
    xmlpath = strcat(xmlpath, 'xml');
    
    ObjectList(n).xml = xmlpath;
    ObjectList(n).class = getClass(xmlpath);
    fprintf(' - %s\n', ObjectList(n).class);

    if isempty(ClassList)
        ClassIndex = 0;
    else
        temp = cellstr(char(ClassList(:).name));
        ClassIndex = find(strcmp(ObjectList(n).class, temp), 1);
        %There is an issue with how many arguments are given due to the way
        %I index the names. I wanted to use the index in the Class List to
        %identify the class, but I wonder if I should just put that number
        %down into the structure's themselves.
%        ClassIndex = find(strcmp(ClassList.name(:), ...
%            ObjectList(n).class), 1);
    end

    if ~isempty(ClassIndex) && ClassIndex ~= 0
        %If the class is already found
        ObjectList(n).classIndex = ClassIndex;
    else
        ClassCount = ClassCount + 1;
         ClassList(ClassCount).name = ObjectList(n).class;
%        ClassList.name(ClassCount) = ObjectList(n).class;
        ObjectList(n).classIndex = ClassCount;
    end
    
    clear xmlpath ClassIndex temp
    
    %ClassList needs to support variable length arrays. Maybe using a cell
    %array as part of the structure for each leaf would be the best method

    %Load and Segment image
    Base = imread(ObjectList(n).filename);
    ObjectList(n).baseWidth = size(Base, 2); %# of cols (Width)
    ObjectList(n).baseHeight = size(Base, 1); %# of rows (Height)
    

    %Clean and Prep Image

    %imshow(Base);
    Thres = simpleSegment(Base);
    
    Thres = imcomplement(Thres);
    Thres = imclearborder(Thres, 8);
%     Thres2 = Thres;
%     figure, imshow(Thres);
    
    %I wonder if I should segment the image into regions and aim to
    %classify each regeion as a version of the leaf. Use a mask to create
    %subimages. This could be possible and spiffy. It would work better for
    %an eventual photograph segmentation too. I need to create a manner to
    %announce when image regions are made, so I can double check.

    %Remove artifacts smaller than the width of the image. Not sure how
    %these steps will work with something like a Persian Silk Tree with a
    %lot of small leaves
    Thres = bwareaopen(Thres, ObjectList(n).baseWidth);
    Thres = imfill(Thres, 'holes');
    Thres = bwmorph(Thres, 'erode', ErodeAmount);
    Thres = bwmorph(Thres, 'open', Inf);
%     figure, imshow(Thres);
    
    %At this point, identify the different regions and compare sizes.
    %Ignore regions that fill more than 30% larger than the median value.
    %These should likely be overlapping leaves. - haven't done yet.

    [Region RegCount] = breakImage(Base, Thres, BufferSize, ErodeAmount);
    ObjectList(n).regionCount = RegCount;
    
    %If I wanted to check for strange size regions, this would be the
    %place. I'm not going to do that at the moment though.
    
    %Do I want to continue the above for loop with the edge detection and
    %code to analyze the result? There was some reason I wasn't going to.
    %It might have been due to wanting to remove regions that are well
    %beyond the median image size for the region set. The region
    %information is saved either way, so that isn't so much of an issue to
    %make another for loop. Just want to know if there is a proper reason.

    for r = 1:RegCount

        %This baseArea variable will be wrong. Need to rework it, if it has a
        %point. I wanted to use it to check how populated the threshold image
        %was. /shrug
        Region(r).area = bwarea(Region(r).mask);
        Edged = edge(Region(r).mask, 'canny');

        %Not sure the below lines are needed anymore now that the image is more
        %localized.

        %Edged = bwmorph(Edged, 'bridge');
        %Edged = bwmorph(Edged, 'hbreak');
        %Edged = bwmorph(Edged, 'close', 1);
        Edged = bwmorph(Edged, 'thin', Inf);
        Edged = bwmorph(Edged, 'spur', Inf);
%         figure, imshow(Edged);

        %With the way the region generation works now, I don't know if
        %there is even a purpose in cropping the image. It is likely an
        %unneeded step and will see about removing it down the line.
        Cropped = autoCrop(Edged);
        
        if size(Cropped) ~= 0
            Region(r).croppedArea = size(Cropped, 1) * size(Cropped, 2);
            Region(r).areaRatio = Region(r).area / Region(r).croppedArea;

            %Find the Top-Most Pixel - Just need a starting point
            %[cHeight cWidth] = size(Cropped);

            Root = [2 find(Cropped(2,:), 1)]; %First Top most pixel

            %Move along the edge in a clock-wise manner calcuating the 
            %differences of position as a motion vector

            %Check 8 neighbors of Root starting in a clockwise manner
            [Chain Found] = traceNeighbors(Cropped, Root(1), Root(2));
            [ProChain] = processChain(Chain);
            RedChain = reduceChain(ProChain);
        else
            RedChain = 0;
        end
        
        %Input the chain into the cell array here?
        
        %The Chain is going to be indexed in the ObjectList(n).chain(r)
        ObjectList(n).chain(r).value = RedChain;
        ObjectList(n).chain(r).length = size(RedChain, 1);
        
        clear Chain Found ProChain RedChain Root
        
        %Averaging the values can come down the road in the testing and
        %classifying functions. I think that just creating the data is now
        %finished, so what is needed is to create functions to compare
        %strings.
        %newIndex = size(ClassList(ObjectList(n).classIndex).chain(:), 1);

        %Adjust Vector size to Standard - Don't need this anymore
        
        %I need to classify the image somehow, into a vector form. Then I
        %need to make an array of each plant type. Then I need to hold each
        %vector created, then systematically go through each one and line
        %them up with the previous for the best score, then add them and
        %average them as the class average. I could average between each
        %leaf, as that would give a different result. I don't know which
        %would be closer or more usable. I think averaging as I went would
        %produce a better system, otherwise I would have to match each new
        %leaf to each of the old leaves to find the best match. If I
        %average as I go, then the differences between each leaf will be
        %reduced.

        %Remember to use the string matching algorithm from class to line up
        %the different sizes. Set maximum cost to 2, as that is the largest
        %possible, and rotate the shortest of the two chains.

        %Input Adjusted Vector and Class into Training Structure
    end
end

clear filesjpg r n startIndex RegCount ErodeAmount Cropped Edged Base
clear BufferSize Thres Region

%% Create Trained Data Set
%Here is where I cycle through the ObjectList and find each object of
%each type one by one and average them.

fprintf('Averaging Classes');

for i = 17:ClassCount

    fprintf('\n--Class #%u : %s\n', i, ClassList(i).name);

    %Find all Objects of the desired class
    Index = find([ObjectList(:).classIndex] == i);
    ClassList(i).Avg = [];
    
%     firstFound = 0;

    %Cycle through each object
    for ObjectIndex = Index

        %Cycle through each region in each object
        for r = 1:ObjectList(ObjectIndex).regionCount
            %Find the best match and average as I go
%             ClassList(i).Avg = bestMatch( ClassList(i).Avg, ...
%                 ObjectList(ObjectIndex).chain(r).value);
            if isempty(ClassList(i).Avg)
                fprintf(' ++ First of Class\n');
                
%                 if firstFound
%                     error('First Dupe');
%                 end
                
%                 firstFound = 1;
%                 fprintf(' ++ First of Class %u::%u\n', ...
%                     size(ClassList(i).Avg), ...
%                     size(ObjectList(ObjectIndex).chain(r).value));
                ClassList(i).Avg = double(ObjectList(ObjectIndex).chain(r).value);
            else
                fprintf(' -- Matching\n');
                ClassList(i).Avg = bestMatch( ClassList(i).Avg, ...
                    ObjectList(ObjectIndex).chain(r).value);
            end
        end
    end
end

save('ClassList.mat', 'ClassList');

clear n xmlpath filesjpg