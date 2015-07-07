# ViCoNet
Source code for Visual Co-occurrence Network (ViCoNet)

-------------
Contents
-------------

This code package contains the following files:

- main.m is the code that runs different modes of ViCoNet

Uncomment any of the modes to run ViConet in 

1. active
2. passive
3. weight
4. weight-ideal
5. base-ESVM (without ViCoNet)
6. HMAX-ESVM (without ViCoNet) - default if all modes commented

Training

ViCoNet is learnt offline using Wegmans data annotations for which are located at ./traindata/Annotations/

Testing

Test rois are extracted from another dataset and can be found at ./testdata/rois/
Groundtruth and the HMAX and ESVM scores can be found in corresponding txt files located at ./testdata/
The entire test annotation can be found at ./util/SCAW_102_SceneDataset.xml

----------------
Getting Started
----------------

Open MATLAB (tested of R2014a in Windows) and run main.m

