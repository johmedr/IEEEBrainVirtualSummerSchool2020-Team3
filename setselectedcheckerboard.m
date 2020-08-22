function setselectedcheckerboard(idx)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global nRowsCheckerboard 
global nColsCheckerboard
global selectedRect
subplot(nRowsCheckerboard, nColsCheckerboard, idx) 
delete(selectedRect) 
selectedRect = rectangle("Position", [1,1,399,399], "Curvature", 0.05, "EdgeColor", "r", "LineWidth", 8)
end

