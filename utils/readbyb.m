function [intout] = readbyb()
% readByb(): reads the last data from Byb kit, and reconstructs the value. 

   global serialByb

   high = fread(serialByb, 1, 'uint8');
   if high > 127   
       low = fread(serialByb, 1, 'uint8');
   else
       high = fread(serialByb, 1, 'uint8');
       low = fread(serialByb, 1, 'uint8'); 
   end 
   intout = uint16(uint16(bitand(high,127)).*128);%.*128 will shift it by 7 places
   intout = real(intout + uint16(low));
end

