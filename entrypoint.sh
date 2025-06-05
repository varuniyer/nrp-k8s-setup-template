#!/bin/bash

# Activate virtual environment
source ../.venv/bin/activate

# Move dependency configuration files to the current (working) directory
mv ../pyproject.toml ../uv.lock .

# Run your code
python test_script.py
