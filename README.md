# git-contributions-generator
![build](https://github.com/zlig/git-contributions-generator/actions/workflows/shellcheck.yml/badge.svg)

Generate commits in `git` to create GitHub contributions in particular.

## Usage

The generator is a bash script that can be ran directly from the command line.

```
$ ./generate-git-contributions.sh --help

GIT CONTRIBUTIONS GENERATOR

Simple bash script to generate git contributions
Usage:
  generate-git-contributions.sh [--options] [<arguments>]
  generate-git-contributions.sh -h | --help
Options:
  -h --help  Display this help information.
  --debug    Enable verbose output
  --folder   Folder path of the git repository where to apply changes
  --start    Start time from which the commits are generated
  --end      End time up to which the commits are generated
  --time     Base time aroun which commits are generated
```

## Examples

```
# Generate contributions between the start of September and the end of October
# with commits around the time 13:00 with logging verbosity enabled
./generate-git-contributions.sh \
  --folder /home/user/workspace/example-repo/ \
  --start 2022-09-01 \
  --end 2022-10-23 \
  --time "13:00:00" \
  --debug

```

## Resources

- Bash boilerplate/template: https://github.com/xwmx/bash-boilerplate
- Metaphor generator: http://metaphorpsum.com/sentences/
