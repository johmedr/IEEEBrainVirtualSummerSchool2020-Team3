function [im] = flickeringcheckboards(nRows, nCols, freqArray)
%	flickeringcheckboards Create a figure with flickering checkerboards
%   nRows and nCols control the number of flickerboards 
%   freqArray is an nRows * nCols array containing individual frequencies,
%   with i-th element selecting the i-th checkerboard in row-wise ordering
%   (e.g. for a 3x3 grid, up-right checkerboard is n°3 and down-left
%   cherckerboard is n°7). 
%   User events, such as moving the mouse, will probably impact the figure's refresh rate 
    defaultRefreshFreq = 60;

    basePeriods = 0.5./(freqArray);
    global indivCounters ;
    global nRowsCheckerboard;
    global nColsCheckerboard; 
    global imCheckerboards;
    clear global selectedRect
    clear im
    clf
    nRowsCheckerboard = nRows;
    nColsCheckerboard = nCols; 

    indivCounters = basePeriods;
    width = 50;
    cb = checkerboard(width) > 0.5;
    for row = 1:nRows
        for col = 1:nCols
            idx = (row - 1) * nCols + col;
            subplot(nRows, nCols, idx);
            if row == 1 & col == 1
                im = imshow(cb);
            else
                im = [im imshow(cb)];
            end
        end
    end
    
    imCheckerboards = im;
    tim = timer('ExecutionMode','fixedRate','Period',real(1/defaultRefreshFreq),'TimerFcn',{@flickerCheckerboards, im, basePeriods});
    tic; 
    start(tim);
end

function flickerCheckerboards(obj, evt, im, basePeriods)
    global indivCounters
    
    for i = 1:size(im, 2)
        %drawnow limitrate;
        currTime = toc; 
        if indivCounters(i) > currTime
            indivCounters(i) = indivCounters(i) - currTime;
        else 
            indivCounters(i) = basePeriods(i);
            im(i).CData = ~im(i).CData;
        end
    end
    %drawnow;
    
    tic;
end
