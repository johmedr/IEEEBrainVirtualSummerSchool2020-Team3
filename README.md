# IEEEBrainVirtualSummerSchool2020-Team3

(Subject to several changes soon)

## 1- Collecting data from the Backyard Brain kit
Running the "startdatareader" function will start the background program
which will collect data from the Backyard Brain serial port and write them to 
the global variable "dataByb". dataByb can be used as the most up-to-date data 
from the board. 

``` Matlab
>> startdatareader
>> global dataByb
>> % e.g. plot(dataByb) 
```


## 2- Display the BCI interface
The function `makeflickeringrectangle(position, frequency, curvature)` can be used to display 
flickering shapes on the current figure. 
The function `flickering1d(leftFreq, midFreq, rightFreq)` can be used to display 3 flickering 
shapes with 3 different flickering frequencies. 
