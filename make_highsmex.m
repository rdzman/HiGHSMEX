% This script builds the highsmex.cpp file
%
% Author: Savyasachi Singh

%% Inputs

% Path to the HiGHS library include directory
highsIncludeDir = '.\HiGHS-1.10.0\installcpp20\include\highs';

% Path to folder containing the HiGHS static library
highsLibIncludeDir = '.\HiGHS-1.10.0\installcpp20\lib';

% Path to the highsmex.cpp file
mexSrcFilePath = '.\highsmex.cpp';

%% Build mex file

compilerInfo=mex.getCompilerConfigurations('C++', 'Selected');
compilerVendor=lower(compilerInfo.Manufacturer);
switch compilerVendor
    case 'microsoft'
        compflags='COMPFLAGS="$COMPFLAGS  /std:c++20  /W3 "';

    case 'gnu'
        compflags='CXXFLAGS=''$CXXFLAGS  -std=c++20  -Wall ''';
end

mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibIncludeDir), '-lhighs', '-v', compflags)

% EOF