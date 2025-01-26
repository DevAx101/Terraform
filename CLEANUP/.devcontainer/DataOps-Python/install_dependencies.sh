#!/usr/bin/env bash

## Install dependencies packages: 
    # imagemagick  \
    # postgresql-client \
apt-get update && apt-get install -y --no-install-recommends \
    git curl wget jq make graphviz  \
    gcc build-essential python3-dev \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*