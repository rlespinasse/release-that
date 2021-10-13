#!/usr/bin/env bash

if [ ! -d "$INPUT_SYSTEM" ]; then
  echo "'$INPUT_SYSTEM' isn't a known system, please used one of following system:"
  echo " - semantic-release"
  exit 1
fi

# Use a symbolic link to overcome the limitation of using an environment variable on a 'uses' step
ln -fs "${INPUT_SYSTEM}" .current-system
