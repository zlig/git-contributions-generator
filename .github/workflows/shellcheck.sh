##############################################################################################
#
# GitHub Actions configuration file to validate BASH scripts with ShellCheck
# 
##############################################################################################
name: shellcheck

on: [pull_request, push]

env:
  VERSION: 0.1

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install pre-requisites
        run: sudo apt search shellcheck

