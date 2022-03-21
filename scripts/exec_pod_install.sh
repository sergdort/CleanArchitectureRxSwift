#!/bin/bash
set -euo pipefail

PROJECT_DIR=$(dirname "$PWD")
echo -e "Root dir: \n${PROJECT_DIR}"

pushd "$PROJECT_DIR"
pod --version
pod install --verbose --no-repo-update
popd 


