% This script builds the highsmex.cpp file
%
% Author: Savyasachi Singh
%
% Covered by the MIT License (see LICENSE file for details).
% See https://github.com/savyasachi/HiGHSMEX for more information.

%% Inputs

% link static file distributed by the HiGHS which includes the HiPO solver
if ispc
    highsInstallDir = fullfile('.', 'highs-1.13.1-x86_64-windows-static-apache');
elseif ismac
    highsInstallDir = fullfile('..', 'highs-1.13.1-arm-apple-static-apache');
else
    disp('highsInstallDir variable not defined in make_highsmex.m');
end
% highsInstallDir = fullfile('.', 'HiGHS-1.13.1', 'installcpp20'); % link static file built from source

% Path to the HiGHS library include directory
highsIncludeDir = fullfile(highsInstallDir, 'include', 'highs');

% Path to folder containing the HiGHS static library
highsLibIncludeDir = fullfile(highsInstallDir, 'lib');

% Path to the highsmex.cpp file
mexSrcFilePath = fullfile('.', 'highsmex.cpp');

%% Build mex file

compilerInfo=mex.getCompilerConfigurations('C++', 'Selected');
compilerVendor=lower(compilerInfo.Manufacturer);
switch compilerVendor
    case 'microsoft'
        compflags={ 'COMPFLAGS="$COMPFLAGS  /std:c++20  /W3 "' };

    case 'gnu'
        compflags={ 'CXXFLAGS=''$CXXFLAGS  -std=c++20  -Wall ''' };

    case 'apple'
        compflags={ 'CXXFLAGS="$CXXFLAGS -std=c++20 -mmacosx-version-min=13.4 "', ...
            'LDFLAGS="$LDFLAGS -mmacosx-version-min=13.4 "' };
end

% mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibIncludeDir), '-lhighs', '-v', compflags{:})
if ispc
    mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibIncludeDir), '-lhighs', '-lopenblas', '-v', compflags{:})
elseif ismac
    mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibIncludeDir), '-lhighs', '-lz', ['LDFLAGS=$LDFLAGS -Wl,-framework,Accelerate'], '-v', compflags{:})
else
    disp('Inputs to mex command not defined in make_highsmex.m');
end

% EOF