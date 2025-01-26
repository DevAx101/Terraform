#!/bin/bash

clear
printf "\e[0;32m DevContainer: $(basename $PWD)\e[0m \n $(uname -a) \n"
# devcontainer-info
# tree -a | grep Dockerfile -C 1

echo "[x] Verify Git client":        $(git --version)
echo "[x] Verify jq":                $(jq   --version)
echo "[x] Verify make":              $(make -v)

# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# echo "[x] Verify NVM":               $(nvm --version)
echo "[x] Verify Node.js":           $(node --version)
echo "[x] Verify npm":               $(npm --version)

# nvm ls-remote
# nvm install 20 && nvm use v20
# nvm alias default v20.10.0
echo "[x] Verify origin yarn":       $(yarn --version)
echo "Configuring to use Yarn 3.5.0 rather than 1.22.22"
sudo corepack enable
corepack prepare yarn@3.5.0 --activate
echo "[x] Verify yarn":              $(yarn --version)

echo "[x] Verify AWS CLI version 2": $(aws --version)
# npx aws-cdk@latest --version
echo "[x] Verify CDK":               $(cdk --version)

echo "[x] Verify Python":            $(python -V)
echo "[x] Verify Python3":           $(python3 -V)
echo "[x] Verify Pip3":              $(pip3 -V)
echo "[x] Verify Pip":               $(pip -V)
echo "[x] Verify Jupyter Lab":       $(jupyter lab --version)
echo "[x] Verify jupyter lab list:": $(jupyter lab list)
# echo "[x] Verify pip freeze:"        $(pip freeze)

pip install --upgrade pip
# if [ -f requirements.txt* ]; then pip install --no-cache-dir -r requirements.txt; else pip install --upgrade jupyterlab ipykernel ipywidgets pandas numpy scipy statsmodels matplotlib seaborn plotly scikit-learn; fi
# pip3 install --no-cache-dir -r .devcontainer/requirements.txt

# echo "[x] Verify Java":              $(java -version)

# echo "[x] Verify K3s":               $(k3s -v)
echo "[x] Verify K3D":               $(k3d --version)
# echo "[-] Verify minikube":          $(minikube version)
# echo "[-] Verify eksctl":            $(eksctl version)
echo "[x] Verify kubectl":           $(kubectl version --client)
echo "[x] Verify helm3":             $(helm version --short)
# curl -sS https://webinstall.dev/k9s | bash
echo "[x] Verify k9s":               $(k9s version --short)

echo "[x] Verify terraform":         $(terraform -v)
echo "[x] Verify terraform-docs":    $(terraform-docs -v)
echo "[x] Verify tfsec":             $(tfsec -v)
echo "[x] Verify tflint":            $(tflint -v)
echo "[x] Verify terragrunt":        $(terragrunt -v)
echo "[x] Verify sentinel":          $(sentinel -v)

echo "[x] Verify atlantis":          $(atlantis version)
echo "[x] Verify ngrok":             $(ngrok --version)

# echo "TODO: WIP ..."

# git config --global --add safe.directory ${containerWorkspaceFolder}

# echo "Running adminer Database management ..."
# docker run -p 8080:8080 -e ADMINER_DEFAULT_SERVER=postgre adminer

# echo "git lfs ..."
# git lfs install
# git lfs track "*.csv"

# echo "Installing Minikube ..."
# cd k8s
# ./minikube.sh

# echo "Running adminer Database management ..."
# docker run -p 8080:8080 -e ADMINER_DEFAULT_SERVER=postgre adminer

# echo "MLFlow"
# EXPOSE 5000
# CMD mlflow server \
#     --host 0.0.0.0 \
#     --port 5000 \
#     --default-artifact-root ${BUCKET} \
#     --backend-store-uri mysql+pymysql://${USERNAME}:${PASSWORD}@${HOST}:${PORT}/${DATABASE}

# echo "#########################################################"
# _logger "[+] 3.1. Installing XXX"
# echo "#########################################################"
# 
# GITHUB_URL="user/XXX"
# ## Identify the CPU type (M1 vs Intel)
# if [[ $(uname -m) ==  "aarch64" ]] ; then
#   CPU="arm64"
# elif [[ $(uname -m) ==  "arm64" ]] ; then
#   CPU="arm64"
# else
#   CPU="amd64"
# fi
# version=$(curl https://api.github.com/repos/$GITHUB_URL/releases/latest --silent | jq ".tag_name" -r)
# KF_VERSION=$(echo $version | sed 's/v//g') ## get rid of 'v' from version number
# KF_PLATFORM=$(echo $(uname -s) | sed -e 's/\(.*\)/\L\1/')
# KF_TAR_FILENAME=XXX_${KF_VERSION}_${KF_PLATFORM}_$CPU.tar.gz
# curl -o /tmp/$KF_TAR_FILENAME -L -k https://github.com/GITHUB_URL/releases/download/v${KF_VERSION}/$KF_TAR_FILENAME
# tar -xvf /tmp/$KF_TAR_FILENAME -C /tmp/
# sudo mv /tmp/XXX /usr/local/bin/XXX
# sudo chmod +x /usr/local/bin/XXX

## K3d
# k3d cluster list
# kubectl config get-contexts