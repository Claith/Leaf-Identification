%Christopher Smith
%Term Project
%
%
%

function [Region RegCount] = breakImage(Base, BW, BufferSize, ErodeAmount)

    Region = struct([]);
    
    [height width] = size(BW);
    
    [Regions RegCount] = bwlabel(BW, 4);
    
    for r = 1:RegCount
        %I need to repeat the processing for each leaf, this needs to be
        %seperate from the rest of the training script so that I can cull
        %the results. This means I need to store the regions in a different
        %structure for just this loop.
        
        %This entire method to find the top left and bottom right points
        %for the cut out are completely incorrect. At worst, I'll need to
        %implement a double for loop, or better yet a single for loop that
        %has two variables tracking the first and last index that fit the
        %criteria.
        
        top = 0;
        bottom = 0;
        near = width;
        far = 0;
        located = 0;
        
        for l = 1:height
            temp = find(Regions(l, :) == r, 1, 'first');
            if temp < near
                near = temp;
                
                %This should call on the first pixel found. No need to call
                %it otherwise, so should be a slim faster in here
                if top == 0
                    top = l;
                    located = 1;
                end
            end
            
            temp = find(Regions(l, :) == r, 1, 'last');
            if temp > far
                far = temp;
            end
            if located && ~isempty(temp)
                bottom = l;
            elseif located && isempty(temp)
                %Stop seaching
                l = height; %#ok<FXSET>
            end
        end
        
        clear temp located l
        
        %[M N] = find(Regions == r, 1, 'first');
        
        Region(r).Start = [top near];%[M N];
        
        %[M N] = find(Regions == r, 1, 'last');

        Region(r).End = [bottom far];%[M N];
        
        %clear M N
        clear top bottom near far
        
        %Likely an easier way to do this, as it should be a common task
        minXB = min(Region(r).Start(2), Region(r).End(2)) - BufferSize;
        maxXB = max(Region(r).Start(2), Region(r).End(2)) + BufferSize;
        minYB = min(Region(r).Start(1), Region(r).End(1)) - BufferSize;
        maxYB = max(Region(r).Start(1), Region(r).End(1)) + BufferSize;
        
        minX = min(Region(r).Start(2), Region(r).End(2));
        maxX = max(Region(r).Start(2), Region(r).End(2));
        minY = min(Region(r).Start(1), Region(r).End(1));
        maxY = max(Region(r).Start(1), Region(r).End(1));
        
        %So the buffer is laid out all around the image, so simply adding
        %the BufferSize to the image should offset it enough to center it
        %into the region mask before it is applied to the base image.
        
        minXBOffset = 0;
        %minXOffset = 0;
        maxXBOffset = 0;
        %maxXOffset = 0;
        
        minYBOffset = 0;
        %minYOffset = 0;
        maxYBOffset = 0;
        %maxYOffset = 0;
        
        %Check for out of bounds - Images start at 1, not 0
        if minXB < 1
            minXBOffset = 1 - minXB;
            minXB = 1;
        end
        if maxXB > width
            maxXBOffset = maxXB - width;
            maxXB = width;
        end
        if minYB < 1
            minYBOffset = 1 - minYB;
            minYB = 1;
        end
        if maxYB > height
            maxYBOffset = maxYB - height;
            maxYB = height;
        end
        
        if minX < 1
%             minXOffset = 0 - minX;
            minX = 1;
        end
        if maxX > width
%             maxXOffset = maxX - width;
            maxX = width;
        end
        if minY < 1
%             minYOffset = 0 - minY;
            minY = 1;
        end
        if maxY > height
%             maxYOffset = maxY - height;
            maxY = height;
        end
        %Safe now
        
        Region(r).height = maxYB - minYB;
        Region(r).width = maxXB - minXB;
        
        Region(r).mask = false([Region(r).height Region(r).width]);
        
        %Need to make a min/max combination for the Thres( : , : ) code
        %below. It can't have been altered by the BufferSize like the ones
        %above.
        
        %Need to fix this line properly now. Just changing the buffersize
        %isn't going to solve it.
        
%         Region(r).mask(BufferSize + minYBOffset : ...
%             Region(r).height - BufferSize - maxYBOffset, ...
%             BufferSize + minXBOffset : ...
%             Region(r).width - BufferSize - maxXBOffset) = ...
        Region(r).mask(BufferSize : Region(r).height- BufferSize, ...
            BufferSize : Region(r).width - BufferSize) = ...
            BW(minY + minYBOffset: maxY - maxYBOffset, ...
            minX + minXBOffset: maxX - maxXBOffset);
        
        Region(r).mask = bwmorph(Region(r).mask, 'dilate', ErodeAmount+1);
        
        Temp = Base(minYB + 1 : maxYB, minXB + 1 : maxXB, :);
        Temp = simpleSegment(Temp);
        Temp = imcomplement(Temp);
        
        %Apply the mask here
        [M N] = find(Region(r).mask);
        Ind = size(M,1);
        
        Region(r).mask = false([Region(r).height Region(r).width]);
        
        for x = 1:Ind
            Region(r).mask(M(x), N(x)) = Temp(M(x), N(x));
        end
        
        Region(r).mask = bwareaopen(Region(r).mask, Region(r).width);
        Region(r).mask = imfill(Region(r).mask, 'holes');

%         figure, imshow(Region(r).mask);
        
        clear Temp M N minX minY maxX maxY minXB maxXB minYB maxYB Ind x
        clear minXBOffset maxXBOffset minYBOffset maxYBOffset
%         clear minXOffset maxXOffset maxYOffset minYOffset
    end

end