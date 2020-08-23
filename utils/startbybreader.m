function startbybreader(maximumRecordingData, sliceSize) 
% startdatareader: starts a task which is called every 'period'. The task
% will move a slice of a certain size into a global array, global dataByb. 
% Timer minimal period the 1e-3, transfering slices of data allows to use a 
% period of 1e-2 (100Hz) without loosing data (ByB freq. is 10000Hz). 
% The maximal data stored can be increased to store more data, it
% determines the length of dataByb which contains the maxDataBybSize last
% data. 
    connected = 0
    while connected == 0
        connected = connectbyb()
    end
    
    clear global dataByb
    clear global eventByb
    global maxDataBybSize
    global maxEventBybSize
    maxDataBybSize = maximumRecordingData;
    maxEventBybSize = int32(maxDataBybSize/sliceSize); 
    tim = timer('ExecutionMode','fixedRate','Period',1e-1,'TimerFcn', {@readslice, sliceSize});
    start(tim)
end

function readslice(obj, evt, sliceSize) 
    global serialByb 
    global dataByb
    global maxDataBybSize
    global eventByb 
    global selectedIdx
    global maxEventBybSize
       
    if serialByb.NumBytesAvailable > sliceSize
        slice = read(serialByb, sliceSize, 'uint8');
        if slice(1) < slice(2)
            slice = slice(2:sliceSize);
        end 

        for i = 1:(sliceSize/2 - 1)
           high = slice(2*i) ;
           low = slice(2*i + 1);
           outslice(i) = uint16(uint16(bitand(high,127)).*128);%.*128 will shift it by 7 places
           outslice(i) = real(outslice(i) + uint16(low));
        end
        if isempty(dataByb)
            dataByb = [outslice];
            eventByb = [selectedIdx];
        else
            dataByb = [dataByb outslice];
            eventByb = [eventByb selectedIdx];
        end
        nData = size(dataByb, 2);
        nEvts = size(eventByb, 2); 
        if  nData > maxDataBybSize
            dataByb = dataByb(nData - maxDataBybSize + 1:nData);
            eventByb = eventByb(nEvts - maxEventBybSize + 1:nEvts);
        end
    end
end
