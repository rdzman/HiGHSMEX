
# HiGHSMEX

MATLAB mex interface to the [HiGHS optimization library.](https://github.com/ERGO-Code/HiGHS)\
*HiGHSMEX is not a part of the official HiGHS distribution.*\
\
HiGHSMEX is built with HiGHS v1.13.0.
## Pre-compiled mex file

For 64-bit Windows and macOS users the pre-compiled mex files *highsmex.mexw64* and *highsmex.mexmaca64* are provided so you do not have to install HiGHS on your system or, compile the mex file. \
Thanks to [Ray Zimmerman](https://github.com/rdzman) for providing help with the compilation of the mex file on macOS platform.
## Instructions for compiling from source

1. Download or clone the HiGHS code. The *highsmex.cpp* file needs to be compiled with C++20 switch, hence it would be advisable to compile HiGHS with C++20 switch. To do so modify the CMakeLists.txt of HiGHS by changing the line 29 ```set(CMAKE_CXX_STANDARD 11)``` to ```set(CMAKE_CXX_STANDARD 20)``` and line 301 ```set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")``` to ```set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20")```. Install HiGHS as described [here.](https://github.com/ERGO-Code/HiGHS/tree/master/cmake) This should create a static library named *highs* e.g., *highs.lib* on Windows.\
**Note for macOS users** Your cmake command should look like the following \
`cmake -S <path-to-source> -B <path-to-build> -DBUILD_SHARED_LIBS=OFF -DZLIB=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET=13.4`
2. Open script named *make_highsmex.m* in MATLAB and specify the inputs. Then execute the script. This should create a mex file named highsmex.mex* e.g., highsmex.mexw64 on 64-bit Windows.\
I do not have access to MATLAB on a Linux system so I cannot build the mex file myself. The above instructions should work on Linux system also. I am willing to provide assistance to anyone who wants to build the mex file on Linux.

## Documentation

HiGHS documentation is available [here.](https://ergo-code.github.io/HiGHS/stable/) A MATLAB function named *callhighs* is the interface to the HiGHS library. Run ```help callhighs``` on MATLAB command prompt to see the help on the input and output parameters of the callhighs function. Also, see the MATLAB script *example_callhighs.m* for various examples of usage.

**Caution:** Do not call the *highsmex* function directly, and only use the *callhighs* function.

HiGHSMEX provides access to almost all the capabilities of HiGHS library except the following
+ Reading problem data from a model file. 
+ Setting names for the rows and columns of the model, or setting name for the objective.
+ Advanced features described [here.](https://ergo-code.github.io/HiGHS/stable/guide/advanced/)
+ HiGHS callbacks.

Newer releases of MATLAB from R2024 include HiGHS as the LP and MILP solver. The advantages of HiGHSMEX are
+ It can be used by MATLAB users with versions older than R2024.
+ It can be used by MATLAB users with no access to MATLAB's Optimization Toolbox.
+ It is quick and easy to integrate the new releases of HiGHS as they become available.
+ Most of the features of HiGHS are available including QP, multi-objective LP, and, hot-starting.
+ Provides access to all the options of HiGHS.
## License
HiGHSMEX is covered by the [MIT](https://choosealicense.com/licenses/mit/) license.

