#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="${DIR}/node_modules/.bin"
if [[ $PATH != "$BIN_DIR"* ]]; then
  export PATH="${DIR}/node_modules/.bin:${PATH}"
fi
export PS1="nicar-2023:command-line-mapping$ "
