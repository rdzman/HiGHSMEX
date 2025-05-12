
# HiGHSMEX

MATLAB mex interface to the [HiGHS optimization library.](https://github.com/ERGO-Code/HiGHS)\
*HiGHSMEX is not a part of the official HiGHS distribution.*
## Pre-compiled mex file

For 64-bit Windows users the pre-compiled mex file *highsmex.mexw64* is provided so you do not have to install HiGHS on your system or, compile the mex file. 
## Instructions for compiling from source

1. Download and install HiGHS as described [here.](https://github.com/ERGO-Code/HiGHS/tree/master/cmake)
   This should create a static library named *highs* e.g., *highs.lib* on Windows.
2. Open script named *make_highsmex.m* in MATLAB and specify the inputs. Then execute the script. This should create a mex file named highsmex.mex* e.g., highsmex.mexw64 on 64-bit Windows. Note that the *highsmex.cpp* file needs to be compiled with C++20 switch, hence it would be advisable to compile HiGHS with C++20 switch. To do this modify the CMakeLists.txt of HiGHS by changing the line ```set(CMAKE_CXX_STANDARD 11)``` to ```set(CMAKE_CXX_STANDARD 20)```.
I do not have access to MATLAB on a Linux system so I cannot build the mex file myself. The above instructions should work on Linux system also. I am willing to provide assistance to anyone who wants to build the mex file on Linux.

## Documentation

HiGHS documentation is available [here.](https://ergo-code.github.io/HiGHS/stable/) A MATLAB function named *callhighs* is the interface to the HiGHS library. Run ```help callhighs``` on MATLAB command prompt to see the help on the input and output parameters of the callhighs function. Also, see the MATLAB script *example_callhighs.m* for various examples of usage.

**Caution:** Do not call the *highsmex* function directly, and only use the *callhighs* function.

HiGHSMEX provides access to almost all the capabilities of HiGHS library except the following
+ Reading problem data from a model file. 
+ Setting names for the rows and columns of the model, or setting name for the objective.
+ Advanced features described [here.](https://ergo-code.github.io/HiGHS/stable/guide/advanced/)
