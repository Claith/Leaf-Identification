%Christopher Smith
%Term Project
%
%Processes the chain to measure the difference between a pixel and the next
%instead of locating the next.
%

function [Chain] = processChain(LocationChain)
    
    ChainLength = size(LocationChain, 1) - 1;
    Chain = zeros([ChainLength 1]);
    
    for n = 1:ChainLength
        Chain(n) = LocationChain(n+1) - LocationChain(n);
        
        %Had to put in some special cases
        %Largest possible value should be 2 in practice
        if Chain(n) == 6
            Chain(n) = -2;
        elseif Chain(n) == -6
            Chain(n) = 2;
        elseif Chain(n) == 7
            Chain(n) = -1;
        elseif Chain(n) == -7
            Chain(n) = 1;
        end
    end
    
    clear n ChainLength
end