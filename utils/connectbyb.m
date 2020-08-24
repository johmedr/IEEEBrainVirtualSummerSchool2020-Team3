function [byb_connected] = connectbyb()
%connectbyb Connects to Backyard brain Kit. Returns 1 when connected. 
%   Serial port is then available in global serialByb.
    port = seriallist 
    if isempty(port)
        error("No device connected");
    end
    baudrate = 230400;
    byb_connected = 0;
    n_trials = 100;
    
    global serialByb
    if verLessThan('matlab', '9.7')
    
    
        serialByb = serial(port, 'BaudRate', baudrate); 
        fopen(serialByb) 
    else 
                
        for trials = 1:n_trials
            try
                serialByb = serialport(port, baudrate)
                byb_connected = 1;
                break;
            catch err
                continue;
            end
        end
    end
end

