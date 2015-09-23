%Christopher Smith
%Term Project
%
%Simple function that auto-crops a binary image;
%It leaves a 1 pixel wide empty range around image

function [Cropped] = autoCrop(I)
    width = size(I, 2);
    height = size(I, 1);
    
    minX = width;
    minY = height;
    maxX = 0;
    maxY = 0;
    
    for x = 1:width
        for y = 1:height
            %I'm sure this can be optimized some how. Out of the range of
            %what needs to be done at this moment though.
            if I(y, x) == 1
                if x < minX
                    minX = x;
                end
                if y < minY
                    minY = y;
                end
                if x > maxX
                    maxX = x;
                end
                if y > maxY
                    maxY = y;
                end
            end
        end
    end
    
    Cropped = I(minY-1:maxY+1, minX-1:maxX+1);
    
    clear x y minX minY maxX maxY width height
    return
end