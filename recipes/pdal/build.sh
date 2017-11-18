#!/bin/bash

# pushd swig/python

$PYTHON setup.py build_ext \
    --include-dirs $INCLUDE_PATH \
    --library-dirs $LIBRARY_PATH
# $PYTHON setup.py build_py
# $PYTHON setup.py build_scripts
$PYTHON setup.py install

# popd