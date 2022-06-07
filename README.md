# dgs_gravimeter
A matlab gui to process data from a dgs gravimeter.
Written in Matlab R2019a, tested on Mac.
Copyright (c) 2022, Jasmine Zhu / PFPE @ Woods Hole Oceanographic Inst.
All rights reserved.

User guide:
1. Edit Parameters.m file, 
2. Open Matlab, in the command window, type DgS_Processing to start the GUI.
3. Press Load Raw DGS Data button, and select raw dgs data. Wait until the next button is activated.
4. Press Load POSMV INGGA button, and select navigation data.
5. PlotFAA - plot free air anomaly. The free air anomaly = raw gravity + latitude correction + eotvos correction + tide correction. A gaussian filter with a preset filter length of 240 sec is applied prior to plotting.
6. Plot Cross Coupling Corrected FAA button - apply a cross coupling correction (ccc) to the free air anomalies calculated above. To 
calculate the ccc, we normally select data sections with a normal ship speed (default is 6 - 15 knots).
7. Export Gravity Data - save to a .mat file with fields of longitude, latitude, measured gravity, ve monitor, vcc monitor, al monitor, ax monitor, latitude correction, eotvos correction, tide correction, free-air anomaly (FAA), FAA after a gaussian filter, cross coupling corrected FAA, ve gain, vcc gain, al gain, and ax gain.
8. Clear All - Clear everything to start over.
