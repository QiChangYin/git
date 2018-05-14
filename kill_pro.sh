#!/usr/bin/env bash

#source ../venv/bin/activate

PROGRAM_PY="./kill_pro.py"
PROGRAM_PYC="./kill_pro.pyc"

if [ -f $PROGRAM_PY ]; then
    python3 $PROGRAM_PY
else
    python3 $PROGRAM_PYC
fi

