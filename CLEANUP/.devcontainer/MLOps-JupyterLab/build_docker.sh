#!/bin/bash

echo "Build the docker ..."

## Setting Parameters
VENV_NAME="mlops"

## Identify the CPU type (M1 vs Intel)
if [[ $(uname -m) ==  "aarch64" ]] ; then
  CPU="arm64"
elif [[ $(uname -m) ==  "arm64" ]] ; then
  CPU="arm64"
else
  CPU="amd64"
fi


label="mlops"
tag="$CPU"
image_name="nnthanh101/$label:$tag"

docker build . -f Dockerfile.MLOps \
               --progress=plain \
               --build-arg VENV_NAME="mlops" \
               -t $image_name

if [[ $? = 0 ]] ; then
echo "Pushing docker..."
docker push $image_name
else
echo "Docker build failed"
fi