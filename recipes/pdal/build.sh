#!/bin/bash

# pushd swig/python
cd python

$PYTHON setup.py build_ext \
    --include-dirs $PREFIX/include \
    --library-dirs $$PREFIX/lib
# $PYTHON setup.py build_py
# $PYTHON setup.py build_scripts
$PYTHON setup.py install

# popd