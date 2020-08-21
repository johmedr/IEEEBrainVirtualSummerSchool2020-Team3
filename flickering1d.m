function [rect] = flickering1d(leftFreq, midFreq, rightFreq)
%flickering1d Creates 3 squares, the left one flickering at leftFreq, right at 
% rightFreq, middle as the mean of left and right frequency
    width = 0.2
    figure
    axis([0 1 0 1])
    [rl, tim1] = makeflickeringrect([0 0.4 width width], leftFreq, 1)
    [rr, tim2] = makeflickeringrect([0.8 0.4 width width], rightFreq, 1)
    [rc, tim3] =  makeflickeringrect([0.4 0.4 width width], midFreq, 1)
    rect = [rl, rr, rc]
end

function [rect, tim] = makeflickeringrect(pos, frequency, curvature)
%makeflickeringrect Creates a flickering rectangle, with given position,
%frequency and edge curvature 
    figure(1)
    rect = rectangle('Position', pos, 'Curvature', curvature);
    tim = timer('ExecutionMode','fixedRate','Period',real(2./frequency),'TimerFcn',{@flicker, rect});
    start(tim);
end

function flicker(obj, evt, rectangle) 
    if sum(rectangle.FaceColor)> 0
        rectangle.FaceColor = [0. 0. 0.];
    else
        rectangle.FaceColor = [1. 1. 1.];
    end
    
end
