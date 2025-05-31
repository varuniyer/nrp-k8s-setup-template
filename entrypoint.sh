#!/bin/bash

# Activate virtual environment
source ../.venv/bin/activate

# Copy dependencies from parent directory
cp ../pyproject.toml ../uv.lock .

# Run your code
python test_script.py
