#!/bin/bash
set -e 

echo -e "\n# AWS auto-completion\ncomplete -C \$(which aws_completer) aws\n" >> ~/.bashrc

# Source so we have autocompletion immediately
source ~/.bashrc
