#!/usr/bin/env bash

VENV_NAME=$1

## Create and activate virtual environment
## && export PATH=/opt/$VENV_NAME/bin:$PATH \
python3 -m venv /opt/$VENV_NAME
source /opt/$VENV_NAME/bin/activate

## Upgrade pip and install requirements
pip install --upgrade pip
pip install --no-cache-dir -r /requirements/requirements.txt

## Make sure the virtual environment is activated for future sessions
echo "source /opt/$VENV_NAME/bin/activate" >> ~/.bashrc
echo "source /opt/$VENV_NAME/bin/activate" >> /etc/bash.bashrc