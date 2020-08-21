function [byb_connected] = connectbyb()
%connectbyb Connects to Backyard brain Kit. Returns 1 when connected. 
%   Serial port is then available in global serialByb.
    port = serialportlist;
    baudrate = 230400;
    byb_connected = 0;
    n_trials = 100;
    
    clear global serialByb
    global serialByb
    
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

