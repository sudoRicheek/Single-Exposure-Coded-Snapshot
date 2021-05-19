# Single Exposure Coded Snapshot

This contains our implementation of **coded aperture compressive temporal imaging** with the aim to recover a sequence of frames from a single coded snapshot. This will lead to temporal gains in video acquisition without a considerable loss in spatial resolution!

## How to reproduce the results ?

Code is present in **/MATLAB_FILES**

```
execute main.m for reproducing the results of "cars" data.
execute flames.m for reproducing the results of "flame" data.
```

## Results 

### Say we have the following 3 frames as input :

<p align="center">
  <img src="/Data/frame1.jpg" width="350" />
  <img src="/Data/frame2.jpg" width="350" /> 
  <img src="/Data/frame3.jpg" width="350" /> 
</p>

### Camera captures a single coded snapshot for these frames :

<p align="center">
  <img src="/Results/3_Frames/3_coded.jpg" width="450" />
</p>

### We perform a patchwise reconstruction using 2D-DCT Basis to get back the original three frames :

<p align="center">
  <img src="/Results/3_Frames/ds3.gif" width="450" />
</p>

### This leads to 3x gain in temporal resolution, with much less loss than a traditional system due to the advantage of inter-frame redundancies.
### Check out /ReconstructedGIFs and /Results for more results!
