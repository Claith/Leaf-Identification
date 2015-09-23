%Christopher Smith
%Term Project
%
%
%Not going to bother rotating arrays to find the best results possible.
%Just going to hope this works well enough for now.

function [AvgChain] = bestMatch(fChain, lChain)

     %going for just getting this done instead of a more memory efficient
     %divide and conquer strategy. Time is the issue
     
     %if empty, return
     if ~numel(lChain)
         AvgChain = fChain;
         return
     end

     i = size(fChain, 1)+1;
     j = size(lChain, 1)+1;
     
     d = 1; %epsilon, just looks like a 'd'; cost of skipping a letter
     
     %Make array
     A = zeros([i j 2]);
     A(2:i,1, 1) = d:d:((i-1)*d);
     A(1, 2:j, 1) = d:d:((j-1)*d);
     
%      fprintf('Finding best alignment  ');
     %Generate array values
     for x = 2:i
         for y = 2:j
             
             %How well the values match
%              fprintf('%5s %5s', fChain, lChain);
             a = abs(fChain(x-1) - lChain(y-1));
             
             %Just found out about a diff(A) function. Spiffy
             delta = a + A(x-1, y-1, 1);
             ygap = d + A(x-1, y, 1);
             xgap = d + A(x, y-1, 1);
             
             res = [ygap; delta; xgap];
             smallest = min(res);
             
             A(x, y, 1) = smallest;
             
             %Traces the path
             resSmall = find(res == smallest);
             if 2 == resSmall
                 A(x, y, 2) = 2; %Match
             elseif 1 == resSmall
                 A(x, y, 2) = 1; %y gap
             else
                 A(x, y, 2) = 3; %x gap
             end
         end
     end
     
     clear delta ygap xgap x y smallest resSmall res
     
     %Both arrays can have gaps. I need to find a method to track the gaps
     %effectively and resort the arrays as I go. Wouldn't this just
     %continually grow the array or would it reach a point where it can fit
     %anything?
     
     %I can't change the array in the for loop as it is generating the best
     %cases, and hasn't decided the end yet. So the thing is, no matter
     %what, I need to work backwards. Simply going to the lowest number
     %isn't going to work typically.
     
     %Pad array - padarray()
     
     %Instead of following the path back to the source, then work from the
     %front, I'll work from the back and remove the front zeros
     
     %Maximum length possible. First column is the first chain, the second
     %the second chain
     
%      fprintf('Averaging\n');
     
     Count = i+j-2;
     yInd = j-1;
     xInd = i-1;
     AvgChain = double(zeros([Count 1]));
     
%      fprintf('%u %u', xInd, yInd);
     
     %While count is greater than 0, and yInd and xInd are not 0
     while Count && (yInd || xInd)
%      for x = i:-1:2
%          for y = j:-1:2

%          fprintf('%u', A(xInd+1, yInd+1, 2));
         if A(xInd+1, yInd+1, 2) == 1
             %Y is skipped
             AvgChain(Count) = fChain(xInd);
             xInd = xInd - 1;
         elseif A(xInd+1, yInd+1, 2) == 2
             %Both are averaged
             AvgChain(Count) = double(fChain(xInd)) + ...
                 double(lChain(yInd)) / 2;
             xInd = xInd - 1; 
             yInd = yInd - 1; 
         elseif A(xInd+1, yInd+1, 2) == 3
             %X is skipped
             AvgChain(Count) = lChain(yInd);
             yInd = yInd - 1;
         else
             AvgChain(Count) = 0; %Filler
         end

         Count = Count - 1;
%          end
     end
     
     %Place values into optimal positions
     
     %Add and Average here
     
     %Clean up the resulting Chain - removes trailing 0s
     AvgChain = AvgChain(find(AvgChain,1,'first'):find(AvgChain,1,'last'));
     
end