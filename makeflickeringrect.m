function [rect, tim] = makeflickeringrect(pos, frequency, curvature)
%makeflickeringrect Creates a flickering rectangle, with given position,
%frequency and edge curvature 
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
