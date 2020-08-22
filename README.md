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
The function `makeflickerincherckerboard(nRows, nCols, freq)` can be used to display 
flickering checkerboards on the current figure. Displays a grid of $nRows \times nCols$ 
checkerboards. Individual frequencies are given in the 1D array `freq`, using a row-wise ordering 
(e.g. for a 3x3 grid, upper-right is n°3 and lower-left is n°7). 

## 3- Start all at once 
``` Matlab 
>> startbci
``` 
