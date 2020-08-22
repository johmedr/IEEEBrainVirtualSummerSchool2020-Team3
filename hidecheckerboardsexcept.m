function hidecheckerboardsexcept(idx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    global imCheckerboards; 
    if idx > 0
        for i = 1:size(imCheckerboards, 2) 
            imCheckerboards(i).AlphaData = 0.1
        end
        imCheckerboards(idx).AlphaData = 1
    else
        for i = 1:size(imCheckerboards, 2) 
            imCheckerboards(i).AlphaData = 1
        end
    end
end

