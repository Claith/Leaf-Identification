%Christopher Smith
%Term Project
%
%
%Reduces a given Neighbor Chain.
%
%1. Checks for chain of similiar neighbors, removing in between entries
%  -Allows for counting neighbors into a chain. eg. 2 would check 1, 2, 3
%2. Reduces Chain Count to a passed number
%
%Not sure what to do if the chain gets too small. I suppose I could pad it
%with 0s and have a special case. This chain isn't what I want to measure
%either way. I'll need to process it before this.

%I need to adjust how this works. It needs to remove all 0s from the Chain
%and then it needs to do something with repeated values

function [Cleaned] = reduceChain(Chain)
%    Cleaned = zeros([ChainSize 1]);
%    CleanedIndex = 1;
    
    %cycle through the Chain and find repeated values
%    chainCount = size(Chain, 1);
    
    %Remove all 0s from the chain.
    Cleaned = Chain(find(Chain)); %#ok<FNDSB>
    
    
%    firstNode = 0; %if 0, then firstNode isn't set
%    for n = 1:chainCount
%        nextNode = Chain(n);
        
%        if firstNode == 0
%            firstNode = Chain(n);
            
            %Set first node in chain
%            Cleaned(CleanedIndex) = firstNode;
%            CleanedIndex = CleanedIndex + 1;
            
%        elseif find(firstNode - Range <= nextNode & ...
%            nextNode <= firstNode + Range)
            %Just continues with searching for the next node. I know this
            %setup is wrong, but gonna ignore it for now
%            disp('Node Fine');
%        else
%            Cleaned(CleanedIndex) = nextNode;
%            CleanedIndex = CleanedIndex + 1;
%            firstNode = nextNode;
%            disp('Set');
%        end
%    end
    
    %Check size using CleanedIndex, and adjust
end