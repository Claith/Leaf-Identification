%Christopher Smith
%Term Project
%
%Assumes BW Image passed in has a 1 pixel buffer around the image
%
%Traces through nearby neighbors returning a vector of chaining neighbors
%as given below.
%
%[8 1 2;
% 7 0 3;
% 6 5 4]
%
%There is a special case in which an angle changes so fast and the
%resolution is so small that it can fail and then cut off the chain,
%because this function removes nearby pixels as it progresses so that they
%aren't checked again.

function [Chain Found] = traceNeighbors(I, xStart, yStart)
    nextNode = [xStart; yStart];
    %width = size(I, 2);
    %height = size(I, 1);
    
    totalPoints = size(find(I), 1);
    Found = 1; %Starts with one because of base point

    %I may need to resize this, but hopefully the cleaning of the image got
    %rid of all artifacts
    Chain = zeros([totalPoints 1]);
    
    %I need to decide if I want this function to create the vector chain
    %that I want as a final solution, or just simply trace along the
    %neighbors and return the chain listing which neighbor is choosen as
    %the next pixel
    
    %I think just returning the choosen neighbor would be best. I can then
    %create another function to read and simplify the chain. Checking
    %repeated neighbors, removing those unneeded ones. Counting neighbors
    %next to repeated values to be included in a chain. ex. East would also
    %allow North East and South East into the chain, but not others.
    
    %When checking for a match, rotate through possible and track the best
    %match, using that as the class choosen.
    
    nodeFound = 1;

    %runs until a nextNode isn't found
    while nodeFound
        nodeFound = 0;
        
        if I(nextNode(1)-1,nextNode(2))
            %Check North (1)
            %Removes node from possible solutions. It has been found
            I(nextNode(1), nextNode(2)-1:nextNode(2)+1) = 0;
            nextNode(1) = nextNode(1)-1;
            Chain(Found) = 1;
            Found = Found + 1;
            nodeFound = 1;
            
            %Need to purge unneeded neighbors
            
        elseif I(nextNode(1)-1,nextNode(2)+1)
            %Check North East (2)
            I(nextNode(1), nextNode(2)) = 0;
            I(nextNode(1)-1, nextNode(2)) = 0;
            I(nextNode(1), nextNode(2)+1) = 0;
            nextNode = [nextNode(1)-1; nextNode(2)+1];
            Chain(Found) = 2;
            Found = Found + 1;
            nodeFound = 1;
        elseif I(nextNode(1), nextNode(2)+1)
            %Check East (3)
            I(nextNode(1)-1:nextNode(1)+1, nextNode(2)) = 0;
            nextNode = [nextNode(1); nextNode(2)+1];
            Chain(Found) = 3;
            Found = Found + 1;
            nodeFound = 1;
        elseif I(nextNode(1)+1, nextNode(2)+1)
            %Check South East (4)
            I(nextNode(1), nextNode(2)) = 0;
            I(nextNode(1)+1, nextNode(2)) = 0;
            I(nextNode(1), nextNode(2)+1) = 0;
            nextNode = [nextNode(1)+1; nextNode(2)+1];
            Chain(Found) = 4;
            Found = Found + 1;
            nodeFound = 1;
        elseif I(nextNode(1)+1, nextNode(2))
            %Check South (5)
            I(nextNode(1), nextNode(2)-1:nextNode(2)+1) = 0;
            nextNode = [nextNode(1)+1; nextNode(2)];
            Chain(Found) = 5;
            Found = Found + 1;
            nodeFound = 1;
        elseif I(nextNode(1)+1, nextNode(2)-1)
            %Check South West (6)
            I(nextNode(1), nextNode(2)) = 0;
            I(nextNode(1)+1, nextNode(2)) = 0;
            I(nextNode(1), nextNode(2)-1) = 0;
            nextNode = [nextNode(1)+1; nextNode(2)-1];
            Chain(Found) = 6;
            Found = Found + 1;
            nodeFound = 1;
        elseif I(nextNode(1), nextNode(2)-1)
            %Check West (7)
            I(nextNode(1)-1:nextNode(1)+1, nextNode(2)) = 0;
            nextNode = [nextNode(1); nextNode(2)-1];
            Chain(Found) = 7;
            Found = Found + 1;
            nodeFound = 1;
        elseif I(nextNode(1)-1, nextNode(2)-1)
            %Check North West (8)
            I(nextNode(1), nextNode(2)) = 0;
            I(nextNode(1)-1, nextNode(2)) = 0;
            I(nextNode(1), nextNode(2)-1) = 0;
            nextNode = [nextNode(1)-1; nextNode(2)-1];
            Chain(Found) = 8;
            Found = Found + 1;
            nodeFound = 1;
        end
        %fprintf('Node Found %u %u\n', nextNode(2), nextNode(1));
    end
    Found = Found - 1; %Pointless, but I'll keep it for now
    
    Chain = Chain(1:Found);
end