#!/bin/bash

set -e # Abort on error.

mkdir build
cd build

BUILD_CONFIG=Release

export PING_SLEEP=30s
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT

dump_output() {
   echo Tailing the last 500 lines of output:
   tail -500 $BUILD_OUTPUT
}
error_handler() {
  echo ERROR: An error was encountered with the build.
  dump_output
  exit 1
}

# If an error occurs, run our error handler to output a tail of the build.
trap 'error_handler' ERR

# Set up a repeating loop to send some output to Travis.
bash -c "while true; do echo \$(date) - building ...; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

## START BUILD
# Get rid of any `.la` from defaults.
rm -rf $PREFIX/lib/*.la

# Force python bindings to not be built.
unset PYTHON

export CFLAGS="-O2 -Wl,-S $CFLAGS"
export CXXFLAGS="-O2 -Wl,-S $CXXFLAGS"
set CMAKE_ARGS=""

if [ $(uname) == Darwin ]; then
    export LDFLAGS="-headerpad_max_install_names"
    export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
    COMP_CC=clang
    COMP_CXX=clang++
    export MACOSX_DEPLOYMENT_TARGET="10.9"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    CMAKE_ARGS="-DCMAKE_BUILD_RPATH:PATH=${PREFIX}/lib -DGDAL_LIBRARY:PATH=$PREFIX/lib/libgdal.dylib"
else
    COMP_CC=gcc
    COMP_CXX=g++
    export LDFLAGS="${LDFLAGS} -lkea -lproj -lpoppler -lxerces-c-3.2 -ldap -lpng16 -lpcre -liconv -lhdf5 -lgeos-3.6.2 -licui18n -licuuc -licudata -lcom_err -lhdf5_hl -lhdf5_cpp -lminizip -luriparser -lkmlbase -lkmldom -lkmlengine -ldapclient -lssl -lssh2 -lcrypto -lmfhdf -ldf -ljpeg -ltiff"
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

cmake -G "Unix Makefiles" ../ \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DGDAL_CONFIG:PATH=$PREFIX/bin/gdal-config \
    -DBUILD_DOCUMENTATION:BOOL=OFF \
    -DBUILD_PLUGIN_PGPOINTCLOUD:BOOL=OFF \
    -DBUILD_PGPOINTCLOUD_TESTS:BOOL=OFF \
    -DWITH_TESTS=OFF \
    ${CMAKE_ARGS}

make -j $CPU_COUNT >> $BUILD_OUTPUT 2>&1
make install >> $BUILD_OUTPUT 2>&1

# The build finished without returning an error so dump a tail of the output.
dump_output

# Nicely terminate the ping output loop.
kill $PING_LOOP_PID
