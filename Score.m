%Christopher Smith
%Term Project
%
%
%

function [Results] = Score(Data, Chain)

    %for each class, run test and find the lowest cost (best score)
    
    Score = zeros([numel(Data) 1]);
    
    for n = 1:numel(Data)
%         fprintf('\n-- %u %s', n, Data(n).Avg);
        fChain = Data(n).Avg;
        lChain = Chain;

        i = size(fChain, 1)+1;
        j = size(lChain, 1)+1;

        d = 2;

       %Make array
        A = zeros([i j 2]);
        A(2:i,1, 1) = d:d:((i-1)*d);
        A(1, 2:j, 1) = d:d:((j-1)*d);

        %Generate array values
        for x = 2:i
            for y = 2:j

                %How well the values match
                a = abs(fChain(x-1) - lChain(y-1));

                delta = a + A(x-1, y-1, 1);
                ygap = d + A(x-1, y, 1);
                xgap = d + A(x, y-1, 1);

                res = [ygap; delta; xgap];
                smallest = min(res);

                A(x, y, 1) = smallest;

                %Traces the path
                resSmall = find(res == smallest);
                if 1 == resSmall
                    A(x, y, 2) = 1; %y gap
                elseif 2 == resSmall
                    A(x, y, 2) = 2; %Match
                else
                    A(x, y, 2) = 3; %x gap
                end
            end
        end
        
        %Place Score into Array
        Score(n) = A(i, j);
    end
    clear delta ygap xgap x y smallest resSmall res
    
    %Find the lowest score in array and return index as result
    Results = find(Score(:) == min(Score(:)), 1);
end