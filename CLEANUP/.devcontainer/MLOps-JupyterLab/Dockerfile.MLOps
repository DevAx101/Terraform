ARG DEBIAN_FRONTEND=noninteractive

## VARIANT= "datascience-notebook" | "base-notebook" | "minimal-notebook" | "r-notebook" | "scipy-notebook" | "tensorflow-notebook" | "pyspark-notebook" | "all-spark-notebook"
ARG VARIANT="minimal-notebook"
FROM quay.io/jupyter/${VARIANT}:latest

## The Teradata JupyterLab Extensions image already sets up the JupyterLab environment with Teradata extensions,
## and the user 'jovyan' for JupyterLab operations, so no further user setup is required here.
# FROM teradata/jupyterlab-extensions:latest
# ENV accept_license=Y
# 
# RUN pip install teradata-jupyterlab-extensions

LABEL maintainer="nnthanh101@gmail.com"
LABEL version="1.0.1"
ENV LANG=C.UTF-8
ENV TZ=Pacific/Auckland

## If additional system packages or Python packages are needed, switch to root, install them, and switch back
USER root
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Install OS packages
RUN apt-get update -qq &&          \
    apt-get install -y --no-install-recommends \
    imagemagick graphviz           \
    build-essential python3-dev    \
    postgresql-client              \
    && apt-get clean               \
    && rm -rf /var/lib/apt/lists/*

## Create a non-root user (jovyan) in a group with the same name.
ARG USERNAME=jovyan
RUN groupadd $USERNAME && usermod -g $USERNAME -a -G users $USERNAME

## Link the /workspace directory to /home/jovyan/workspace
RUN ln -s /workspace/ /home/$USERNAME/

USER $USERNAME