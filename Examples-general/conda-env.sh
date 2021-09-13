#!/bin/bash

## Creating, activating, and managing conda environments (envs)

# List existing envs
conda env list

# Create an environment
conda create --name FastAAI

# Activate env
conda activate FastAAI

# Deactivate an active env
conda deactivate

# Delete an env
conda remove --name FastAAI --all

