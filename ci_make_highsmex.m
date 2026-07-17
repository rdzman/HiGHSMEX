% Used to build the MEX files on GitHub runners
%
% Author: Savyasachi Singh
% Modified by: Ray Zimmerman
%
% Covered by the MIT License (see LICENSE file for details).
% See https://github.com/savyasachi/HiGHSMEX for more information.

%% Inputs
% Expects to find official binary HiGHS distribution, including HiPO solver,
% to be found in HiGHS direcory 1 level up
highsInstallDir = fullfile('..', 'HiGHS');

% Path to the HiGHS library include directory
highsIncludeDir = fullfile(highsInstallDir, 'include', 'highs');

% Path to folder containing the HiGHS static library
highsLibDir = fullfile(highsInstallDir, 'lib');

% Path to the highsmex.cpp file
mexSrcFilePath = fullfile('.', 'highsmex.cpp');

%% Build mex file
compilerInfo=mex.getCompilerConfigurations('C++', 'Selected');
compilerVendor=lower(compilerInfo.Manufacturer);
switch compilerVendor
    case 'microsoft'
        compflags={ 'COMPFLAGS="$COMPFLAGS /std:c++20  /W3 "' };

    case 'gnu'
%         compflags={ 'COMPFLAGS="$COMPFLAGS -std=c++20  -Wall -static-libstdc++ -static-libgcc"' };
        compflags = {
            'COMPFLAGS="$COMPFLAGS -std=c++20 -Wall"'
            'LINKFLAGS="$LINKFLAGS -static-libstdc++ -static-libgcc"'
        };
%        compflags = {
%            'COMPFLAGS="$COMPFLAGS -std=c++20 -Wall"'
%            'LDFLAGS="$LDFLAGS -static-libstdc++ -static-libgcc"'
%        };
%        compflags={ 'CXXFLAGS="$CXXFLAGS  -std=c++20  -Wall"' };
    case 'apple'
        compflags={ 'CXXFLAGS="$CXXFLAGS -std=c++20 -mmacosx-version-min=13.4 "', ...
            'LDFLAGS="$LDFLAGS -mmacosx-version-min=13.4 "' };
end
if ispc         % Windows
    mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibDir), '-lhighs', '-lhighs_extras', '-lopenblas', '-v', compflags{:})
elseif ismac    % macOS
    mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibDir), '-lhighs', '-lhighs_extras', '-lz', ['LDFLAGS=$LDFLAGS -Wl,-framework,Accelerate'], '-v', compflags{:})
elseif isunix   % Linux
    mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibDir), '-lhighs', '-lhighs_extras', '-lopenblas', '-lz', 'LDFLAGS=$LDFLAGS', '-v', compflags{:})
%    mex(mexSrcFilePath, '-R2018a', sprintf('-I"%s"', highsIncludeDir), sprintf('-L"%s"', highsLibDir), '-lhighs', '-lhighs_extras', '-lopenblas', '-lz', 'LDFLAGS=$LDFLAGS -static-libstdc++ -static-libgcc', '-v', compflags{:})
end
