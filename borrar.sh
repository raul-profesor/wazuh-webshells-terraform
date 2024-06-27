#!/bin/bash

# Check if pywinrm module is installed
if pip show pywinrm &> /dev/null; then
    echo "pywinrm module is installed."
else
    echo "pywinrm module is not installed."
fi
