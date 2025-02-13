#!/bin/bash

export HOME=/home/gap

source $JUPYTER_HOME/bin/activate && jupyter notebook --ip=0.0.0.0 --port=8000 --notebook-dir=$NB_HOME --no-browser
