#!/bin/bash

# Activate virtual environment
source ../.venv/bin/activate

# Copy dependencies from parent directory
cp ../pyproject.toml ../uv.lock .

python test_script.py
