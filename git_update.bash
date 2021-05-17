#!/usr/bin/bash
git pull
# git submodule update --recursive --remote
git pull --recurse-submodules
# git pull && git submodule init && git submodule update && git submodule status
