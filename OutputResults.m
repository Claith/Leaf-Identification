%Christopher Smith
%Term Project
%
%
%Output Results

function [match_table] = OutputResults(TestList, ClassList)

    testSize = numel(TestList);
    lCount = numel(ClassList);

    idx = find([TestList(:).classGuess]==0);
    fprintf('Images Unclassified %d times\n',length(idx));
    
    match_table = zeros(lCount,lCount);
    Correct = 0;
    Misclassified = 0;
    Classified = testSize - length(idx);

    for i=1:lCount,
        %What it is
        idx_class = find([TestList(:).classIndex] == i);
        for j=1:lCount,
            %What it thinks it is
            idx = find([TestList(idx_class).classGuess] == j);
            if i == j
                Correct = Correct + length(idx);
            elseif ~isempty(idx)
                Misclassified = Misclassified + length(idx);
            end
            match_table(i,j) = length(idx);
        end
    end
    
    Accuracy = 100 * (Correct / Classified);

    fh = figure;
    if fh
      figure(fh); clf;

      unique_labels = (1:lCount)';
      unique_labels = num2str(unique_labels);

      imagesc(0:lCount-1,0:lCount-1,match_table), 
      set(gca,'Xtick',0:lCount-1,'XtickLabel',unique_labels)
      set(gca,'Ytick',0:lCount-1,'YtickLabel',unique_labels)
      colorbar;
      xlabel('#times classified as')
      ylabel('True labels');
      title([num2str(Correct), ' Correct :: ', num2str(Misclassified), ...
          ' Incorrect :: ', num2str(Accuracy, 4), '% Accuracy'], ...
          'Interpreter','none');
      hold on;
      for i=1:size(match_table,1),
        for j=1:size(match_table,2),
          text(j-1,i-1,sprintf('%2d',match_table(i,j)),'color','white','FontSize',8)
        end
      end
    end
end