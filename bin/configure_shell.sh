#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="${DIR}/node_modules/.bin"
if [[ $PATH != "$BIN_DIR"* ]]; then
  export PATH="${DIR}/node_modules/.bin:${PATH}"
fi
export PS1="%F{red}nicar-2023%f:%F{blue}command-line-mapping%f$ "
