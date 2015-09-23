%Christopher Smith
%csmith49@fau.edu
%Term Project
%
%A very specifically made method to help me identify individual classes
function [Class] = getClass(filename)

    %Pulls out the object's class from the xml file
    
    if ~ischar(filename)
        error('Impossible filename');
    end
    
    ID = fopen(filename);
    
    file = fscanf(ID, '%c');
    
    Start = strfind(file, '<ClassId>');
    End = strfind(file, '</ClassId>');
    
    Class = file(Start+9:End-1);
    
    fclose(ID);
end