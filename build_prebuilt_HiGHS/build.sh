update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 --slave /usr/bin/g++ g++ /usr/bin/g++-12

# clone repository
git clone https://github.com/GenosseFlosse/HiGHSMEX.git # ensure this repository does not need 

#git clone https://github.com/ERGO-Code/HiGHS.git # standard HiGHS master

# build HiGHS
# cd ~/HiGHS
# cmake -S. -B build -DCMAKE_INSTALL_PREFIX=~/highs_install -DBUILD_SHARED_LIBS=OFF -DZLIB=OFF -DBUILD_OPENBLAS=OFF
# cmake --build build --parallel
# cmake --install build

wget https://github.com/ERGO-Code/HiGHS/releases/download/v1.14.0/highs-1.14.0-x86_64-linux-gnu-static-apache.tar.gz
mkdir -p highs_install
tar -xzf highs-1.14.0-x86_64-linux-gnu-static-apache.tar.gz -C highs_install

cd ~/HiGHSMEX 

MATLAB=/opt/matlab

g++ -std=c++20 -O2 -fPIC -pthread \
-DMX_COMPAT_64 \
-DMATLAB_MEX_FILE \
-DMATLAB_MEXCMD_RELEASE=R2018a \
-D_GNU_SOURCE \
-I../highs_install/include/highs \
-I$MATLAB/extern/include \
-I$MATLAB/simulink/include \
-c highsmex.cpp -o highsmex.o

g++ -shared -pthread -Wl,--no-undefined \
-Wl,--version-script,$MATLAB/extern/lib/glnxa64/mexFunction.map \
-Wl,--verbose \
highsmex.o \
../highs_install/lib/libhighs.a \
../highs_install/lib/libopenblas.a \
-L/usr/lib/x86_64-linux-gnu -Wl,-Bstatic -lz -Wl,-Bdynamic \
-L$MATLAB/bin/glnxa64 \
-L$MATLAB/extern/bin/glnxa64 \
-lMatlabDataArray -lmx -lmex -lmat -lm \
-static-libstdc++ -static-libgcc \
-o highsmex.mexa64



echo "highsmex.mexa64 ldd output:"
ldd highsmex.mexa64
echo "highsmex.mexa64 GLIBCXX_ requirements:"
strings highsmex.mexa64 | grep GLIBC_
echo "Build Environment GLIBCXX_ versions:"
strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBCXX_ | sort -V | tail


$MATLAB/bin/matlab -nodesktop -batch "example_callhighs;"