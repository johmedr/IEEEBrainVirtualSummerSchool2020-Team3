function setfocuscheckboard(idx, intensity)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
global nRowsCheckerboard 
global nColsCheckerboard
global focusRect
delete(focusRect)
maxSize = 50
subplot(nRowsCheckerboard, nColsCheckerboard, idx) 
focusRect = rectangle('Position', [200 - intensity * maxSize / 2 ,200 - intensity * maxSize / 2, intensity * maxSize,intensity * maxSize], 'Curvature', 1., 'EdgeColor', [0, intensity, 1 - intensity], 'LineWidth', intensity * maxSize);
end

