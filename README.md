# ViCoNet
Source code for Visual Co-occurrence Network (ViCoNet) based on 
work published in ESTIMedia 2015

If you use this code for evaluation and/or benchmarking, we 
appreciate if you cite an appropriate subset of the following
papers:

@INPROCEEDINGS{estimedia2015,
author={Advani, S. and Smith, B. and Tanabe, Y. and Irick, K. and Sampson, J. and Narayanan, V.},
booktitle={Embedded Systems for Real-time Media (ESTIMedia), 2015 IEEE Symposium on},
title={Visual Co-occurrence Network: Using Context for Large-Scale Object Recognition in Retail},
year={2015},
month={Oct},
pages={},
}

@INPROCEEDINGS{iccad2014,
author={Cotter, M. and Advani, S. and Sampson, J. and Irick, K. and Narayanan, V.},
booktitle={Computer-Aided Design (ICCAD), 2014 IEEE/ACM International Conference on},
title={A hardware accelerated multilevel visual classifier for embedded visual-assist systems},
year={2014},
month={Nov},
pages={96-100},
}

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

Modes 1 and 2 are based on an initial Workshop paper in HPCA 2015.
Modes 3 and 4 are based on ESTIMedia 2015.
Modes 5 and 6 are based on ICCAD 2014 and are baselines for ESTIMedia 2015. 

Training

ViCoNet is learnt offline using Wegmans data annotations for which are located at ./traindata/Annotations/
Images are too big to upload here. Will make it available online soon.

Testing

Test rois are extracted from another dataset and can be found at ./testdata/rois/
Groundtruth and the HMAX and ESVM scores can be found in corresponding txt files located at ./testdata/
The entire test annotation can be found at ./util/SCAW_102_SceneDataset.xml
Images are too big to upload here. Will make it available online soon.

----------------
Getting Started
----------------

Open MATLAB (tested on R2014a in Windows) and run main.m

----------------
License
----------------

This code is published under the MIT License.
Please read LICENSE for more info.

----------------
History
----------------

Version 1.0 (06/18/2015)
 - initial version corresponding to ESTIMedia 2015 paper
