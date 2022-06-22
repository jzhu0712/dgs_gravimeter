# dgs_gravimeter
A matlab GUI to process data from a DgS AT1M gravimeter.
Matlab version:  R2019a 
Tested OS: Mac
Copyright (c) 2022, Jasmine Zhu / PFPE @ Woods Hole Oceanographic Inst.
All rights reserved.

User guide:
0. This code is particularly used for the DgS gravimeter installed on R/V Thompson. 
1. Edit Parameters.m file, and provide the gravity tie info measured before and after (optional) a cruise.
2. Open Matlab, in the command window, type DgS_Processing to start the GUI.
3. Press Load Raw DGS Data button, and select raw dgs data. Wait until the next button is activated. The Raw data file format is:
Time stamp, Text identifier, Dgravity, dlong,dcross, dbeam,	Dpressure, dtemp, rvcc, rve, ral, rax, status, check, latitude, longitude, speed, course and VerticalVelocity, e.g.,
03/04/2022,00:00:02.587,$AT1M_3.61_4621429,-4316,628,730,4081886,209,510,201,33433,560,790,1441,330,4116072,0.0000000000,0.0000000000,0.0000,0.0000,00000122114349
4. Press Load POSMV INGGA button, and select navigation data. For instance,
02/21/2022,00:00:01.476,$INGGA,000001.565,0444.79553,S,10555.48613,W,5,31,0.7,0.77,M,,,4,1015*12
5. PlotFAA - plot free air anomaly. The free air anomaly = raw gravity + latitude correction + eotvos correction + tide correction. A gaussian filter with a preset filter length of 240 sec is applied prior to plotting.
6. Plot Cross Coupling Corrected FAA button - apply a cross coupling correction (ccc) to the free air anomalies calculated above. To 
calculate the ccc, we normally select data sections with a normal ship speed (default is 6 - 15 knots).
7. Export Gravity Data - save to a .mat file with fields of longitude, latitude, measured gravity, ve monitor, vcc monitor, al monitor, ax monitor, latitude correction, eotvos correction, tide correction, free-air anomaly (FAA), FAA after a gaussian filter, cross coupling corrected FAA, ve gain, vcc gain, al gain, and ax gain.
8. Clear All - Clear everything to start over.


* Reference:
1. date2doy.m by Anthony Kendall
% Contact: anthony.kendall@gmail.com
% Copyright 2008 Michigan State University.