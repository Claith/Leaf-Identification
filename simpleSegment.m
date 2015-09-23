%
%
%

function [Result] = simpleSegment(I)
    
    I = rgb2gray(I);  % if image is in RGB convert it to graysclae
    I = double(I);

    thres_new = 120; % arbitrary threshold in the start 
    thres = 0;

    [r c]= size(I);
    
    %There seems to be some images that cause issues with segmentation. One
    %leaf had what looked to be fungus growing on it, and got trapped in
    %this function. Adding this timeout feature to resolve such problems.
    CycleCount = 0;
    CountCutOff = 500;
    
    while (thres ~= thres_new) && (CycleCount <= CountCutOff)
        m1 = 0;
        m2 = 0;
        
        CycleCount = CycleCount + 1;
        
        thres = thres_new;
        
        for i = 1:r  
            for j = 1:c   
                if(I(i,j) >= thres) 
                    m1 = m1 + I(i,j);     
                else
                    m2 = m2 + I(i,j);     
                end
            end
        end
        x = size(find(I >= thres), 1); 
        m1_len = x; 
        
        x = size(find(I < thres), 1);
        m2_len = x;
        
        avg = ((m1 / m1_len) + (m2 / m2_len)) / 2 ;    
        thres_new = avg;     %   thres_new = (m1+m2)/(2*r*c); 
    end
    
    Result = I > thres_new;
    
    %subplot(2,1,1)
    %imshow(uint8(I)) 
    %subplot(2,1,2)
    %imshow(Result)
end