
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include

# Python command to install the script.
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
