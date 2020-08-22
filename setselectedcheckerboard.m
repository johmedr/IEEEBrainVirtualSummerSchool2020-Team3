function setselectedcheckerboard(idx)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    global selectedRect
    global selectedIdx
    delete(selectedRect) 
    if idx > 0
        global nRowsCheckerboard 
        global nColsCheckerboard
        subplot(nRowsCheckerboard, nColsCheckerboard, idx) 
        selectedRect = rectangle("Position", [1,1,399,399], "Curvature", 0.01, "EdgeColor", "r", "LineWidth", 8);
        selectedIdx = idx
    else 
        selectedIdx = 0
    end
end

