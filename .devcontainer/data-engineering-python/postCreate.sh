#!/bin/bash

clear
printf "\e[0;32m DevContainer: $(basename $PWD)\e[0m \n $(uname -a) \n"
# devcontainer-info
# tree -a | grep Dockerfile -C 1

echo "[x] Verify Git client":        $(git --version)
echo "[x] Verify jq":                $(jq   --version)
echo "[x] Verify make":              $(make -v)
# echo "[x] Verify AWS CLI version 2": $(aws --version)

# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# echo "[x] Verify NVM":               $(nvm --version)
echo "[x] Verify Node.js":           $(node --version)
echo "[x] Verify npm":               $(npm --version)

# nvm ls-remote
# nvm install 20 && nvm use v20
# nvm alias default v20.10.0
# npm install -g yarn aws-cdk
echo "[x] Verify yarn":              $(yarn --version)
# echo "[x] Verify CDK":               $(cdk --version)

echo "[x] Verify Python":            $(python -V)
echo "[x] Verify Python3":           $(python3 -V)
echo "[x] Verify Pip3":              $(pip3 -V)
echo "[x] Verify Pip":               $(pip -V)

# echo "[x] Verify Jupyter Lab":       $(jupyter lab --version)
# echo "[x] Verify jupyter lab list":  $(jupyter lab list)
# echo "[x] Verify Conda environment:" $(conda env list)
# echo "[x] Verify pip freeze:"        $(pip freeze)
# pip install --upgrade pip
