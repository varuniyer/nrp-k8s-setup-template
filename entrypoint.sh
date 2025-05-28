#!/bin/bash

# Modify `run.sh` instead of this script.
source .venv/bin/activate
cp pyproject.toml uv.lock $REPO_NAME
cd $REPO_NAME
exec bash run.sh

