###########################################################################################################
#
# GitHub Actions configuration file to validate BASH scripts with ShellCheck (https://www.shellcheck.net/)
# 
###########################################################################################################
name: shellcheck

on: [pull_request, push]

env:
  SHELLCHECK_VERSION: v0.8.0

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install pre-requisites
        run:
	  - curl --silent --location "https://github.com/koalaman/shellcheck/releases/download/"${SHELLCHECK_VERSION}"/shellcheck-"${SHELLCHECK_VERSION}".linux.x86_64.tar.xz" | tar -xJv
	  - sudo cp shellcheck-"${SHELLCHECK_VERSION}"/shellcheck /usr/bin/
          - shellcheck --version
