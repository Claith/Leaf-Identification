%% Delete Photographs

filestrain = dir('./data/train/*.jpg');
filestest = dir('./data/test/*.jpg');

xmlfiles = './data/testwithgroundtruthxml/*';
copyfile(xmlfiles, './data/test/');
%haven't tested it, but apparently it will copy all files in the folder to
%the destination.

filesjpg = cat(1, filestrain, filestest);

%all image files
nfiles = size(filesjpg, 1);

fprintf('number of files: %d\n', nfiles); %print the number of files
for n=1:nfiles
    fprintf('%d: %s\n', n, filesjpg(n).name); %print the image name
    filename = strcat('./data/test/', filesjpg(n).name);
    
    %Load XML
    path = strtok(filename, 'jpg');
    x = strcat(path, 'xml');
    
    d = fopen(x);
    
    e = fscanf(d, '%c');
    fclose(d);
    
    if ~isempty(strfind(e, 'photograph'))
        %delete image and xml
        delete(x, filename);
    end
    
end

%copy xml files to test folder
% nfiles = numel(xmlfiles);

% for n = 1:nfiles
%     filename = strcat('./data/testwithgroundtruthxml/', xmlfiles(n).name);
%     destination = strcat('./data/test/', xmlfiles(n).name);
%     
%     copyfile(filename, destination);
% end

clear n filesjpg filestrain filestest nfiles d x e filename xmlfiles