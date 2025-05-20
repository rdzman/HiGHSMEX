% This script builds the highsmex.cpp file
%
% Author: Savyasachi Singh

%% Inputs

if ismac
    highsInstallDir = '/opt/homebrew';
else
    highsInstallDir = '.\HiGHS-1.10.0\installcpp20';
end

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
        compflags='COMPFLAGS="$COMPFLAGS  /std:c++20  /W3 "';

    case 'gnu'
        compflags='CXXFLAGS=''$CXXFLAGS  -std=c++20  -Wall ''';

    case 'apple'
        compflags='CXXFLAGS="$CXXFLAGS -std=c++20 -mmacosx-version-min=13.4 "';
end

mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibIncludeDir), '-lhighs', '-v', compflags)

% EOF