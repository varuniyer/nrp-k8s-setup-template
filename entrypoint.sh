#!/bin/bash

source .venv/bin/activate

cp pyproject.toml uv.lock $REPO_NAME
cd $REPO_NAME

python test_script.py

