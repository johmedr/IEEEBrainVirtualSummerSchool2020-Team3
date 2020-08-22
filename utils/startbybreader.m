function startbybreader() 
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
    global maxDataBybSize
    maxDataBybSize = 50000;
    tim = timer('ExecutionMode','fixedRate','Period',1e-1,'TimerFcn', {@readslice, 1002});
    start(tim)
end

function readslice(obj, evt, slice_size) 
    global serialByb 
    global dataByb
    global maxDataBybSize
    
    if serialByb.NumBytesAvailable > slice_size
        slice = read(serialByb, slice_size, 'uint8');
        if slice(1) < slice(2)
            slice = slice(2:slice_size);
        end 

        for i = 1:(slice_size/2 - 1)
           high = slice(2*i) ;
           low = slice(2*i + 1);
           outslice(i) = uint16(uint16(bitand(high,127)).*128);%.*128 will shift it by 7 places
           outslice(i) = real(outslice(i) + uint16(low));
        end
        if isempty(dataByb)
            dataByb = [outslice];
        else
            dataByb = [dataByb outslice];
        end
        nData = size(dataByb, 2);
        if  nData > maxDataBybSize
            dataByb = dataByb(nData - maxDataBybSize + 1:nData);
        end
    end
end
