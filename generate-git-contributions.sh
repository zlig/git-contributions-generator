#!/usr/bin/env bash
#    _____            _        _ _           _   _                 
#   / ____|          | |      (_| |         | | (_)                
#  | |     ___  _ __ | |_ _ __ _| |__  _   _| |_ _  ___  _ __  ___ 
#  | |    / _ \| '_ \| __| '__| | '_ \| | | | __| |/ _ \| '_ \/ __|
#  | |___| (_) | | | | |_| |  | | |_) | |_| | |_| | (_) | | | \__ \
#   \_____\___/|_| |_|\__|_|  |_|_.__/ \__,_|\__|_|\___/|_| |_|___/
#                                                                  
#            _____                           _             
#           / ____|                         | |            
#          | |  __  ___ _ __   ___ _ __ __ _| |_ ___  _ __ 
#          | | |_ |/ _ | '_ \ / _ | '__/ _` | __/ _ \| '__|
#          | |__| |  __| | | |  __| | | (_| | || (_) | |   
#           \_____|\___|_| |_|\___|_|  \__,_|\__\___/|_|   
#                                                          
# Usage:
#   generate-git-contributions.sh <options>...
#
# Copyright (c) 2022 zlig @ geld.tech

set -u
set -e
set -E
set -o pipefail
IFS=$'\n\t'

# System variables
_ME="$(basename "${0}")"
_DEBUG_COUNTER=0
_PRINT_HELP=0
_USE_DEBUG=0
_CACHE_PATH=".cache"
_FOLDER_PATH="."
_MAX_ARTICLE=100

# Date and time interval to create commits
_START_DATE="1970-01-01"
_END_DATE="1999-12-31"
_BASE_TIME="11:00:00"

# Semi-random number of commits per day
_NUM_COMMITS=("7" "10" "8" "3" "5" "18" "1" "23")

# Better random generator seeding
RANDOM=$(date +%N | cut -b4-9)


# Functions

debug() {
  if ((${_USE_DEBUG:-0}))
  then
    _DEBUG_COUNTER=$((_DEBUG_COUNTER+1))
    {
      # Prefix debug message
      printf "\n>> %s - %s" "${_DEBUG_COUNTER}" "$@"
    } 1>&2
  fi
}

exit_1() {
  {
    printf "%s %s \n" "$(tput setaf 1)!$(tput sgr0)" "$@"
  } 1>&2
  exit 1
}

warn() {
  {
    printf "%s " "$(tput setaf 1)!$(tput sgr0)"
    "${@}"
  } 1>&2
}

__get_option_value() {
  local __arg="${1:-}"
  local __val="${2:-}"

  if [[ -n "${__val:-}" ]] && [[ ! "${__val:-}" =~ ^- ]]
  then
    printf "%s\\n" "${__val}"
  else
    exit_1 "Requires a valid argument for ${__arg}"
  fi
}

print_help() {
  cat <<HEREDOC
GIT CONTRIBUTIONS GENERATOR

Simple bash script to generate git contributions
Usage:
  ${_ME} [--options] [<arguments>]
  ${_ME} -h | --help
Options:
  -h --help  Display this help information.
  --debug    Enable verbose output
  --folder   Folder path of the git repository where to apply changes
  --start    Start time from which the commits are generated
  --end      End time up to which the commits are generated
  --time     Base time aroun which commits are generated
HEREDOC
}

while ((${#}))
do
  __arg="${1:-}"
  __val="${2:-}"

  case "${__arg}" in
    -h|--help)
      _PRINT_HELP=1
      ;;
    --debug)
      _USE_DEBUG=1
      ;;
    --folder)
      _FOLDER_PATH="$(__get_option_value "${__arg}" "${__val:-}")"
      ;;
    --start)
      _START_DATE="$(__get_option_value "${__arg}" "${__val:-}")"
      date "+%Y-%m-%d" -d "${_START_DATE}" > /dev/null
      ;;
    --end)
      _END_DATE="$(__get_option_value "${__arg}" "${__val:-}")"
      date "+%Y-%m-%d" -d "${_END_DATE}" > /dev/null
      ;;
    --time)
      _BASE_TIME="$(__get_option_value "${__arg}" "${__val:-}")"
      date "+%Y-%m-%d %H:%M:%S" -d "1970-01-01 ${_BASE_TIME}" > /dev/null
      ;;
    -*)
      exit_1 "Unexpected option: '${__arg}'"
      ;;
  esac

  shift
done

# Main processing
process() {
  num_commits=0
  debug  "Generating contributions..."

  # Create and commit a temporary file
  debug "Repository folder ${_FOLDER_PATH} "
  cd "${_FOLDER_PATH}"
  debug "Preparing template ..."
  echo "__MODIFIED__" > generated_contributions.txt.template
  debug "Preparing contributions file ..."
  echo "Generated contributions" > generated_contributions.txt
  git add generated_contributions.txt
  debug "Committing contributions file ..."
  echo ""
  git commit generated_contributions.txt -m "Adds file" --date="${_START_DATE} ${_BASE_TIME}  +0100"

  # Validate dates range
  debug "Start date ${_START_DATE}"
  debug "End date ${_END_DATE}"
  start="${_START_DATE}"
  end="${_END_DATE}"
  declare -a dates_list=()
  if ! [[ $start < $end ]]
  then
    exit_1 printf "Error: end date must be after start date, or incorrect date format (YYYY-MM-DD expected)!\\n"
  fi

  # Generate dates list
  debug "Dates list"
  while ! [[ $start > $end ]]; do
    dates_list+=("$start")
    start=$(date -d "$start + 1 day" +%F)
  done  
  debug '%s  ' "${dates_list[@]}"

  # Fetch random text paragraphs a random number of times and commit them in the current day
  debug "Processing"
  mkdir -p $_CACHE_PATH/
  for current_date in "${dates_list[@]}"
  do
    index=$((RANDOM % "${#_NUM_COMMITS[@]}"))
    repetitions=${_NUM_COMMITS[$index]}
    debug "Applying [ $repetitions ] commits on $current_date $_BASE_TIME +0100"

    for i in $(seq 1 "$repetitions")
    do
      current_time=$(date "+%Y-%m-%d %H:%M:%S"  -d "${current_date} ${_BASE_TIME} ${i}min")
      article_index=$(shuf -i1-$_MAX_ARTICLE -n1)
      current_file="$_CACHE_PATH/$article_index"
      # Fetch and cache paragraph
      if [ ! -f "$current_file" ]; then
        curl -o "$current_file" "http://metaphorpsum.com/sentences/$article_index"
      fi
      TEXT=$(cat $current_file)
      debug "Applying for ${current_time}"
      sed "s/__MODIFIED__/$TEXT/g" generated_contributions.txt.template > generated_contributions.txt
      git commit -a -m "Updating content" --date="$current_time +0100"
      num_commits=$((num_commits+1))
    done

  done

  # Cleanup and remove temporary file
  end_time=$(date "+%Y-%m-%d %H:%M:%S"  -d "${_END_DATE} ${_BASE_TIME} 30min")
  rm -f generated_contributions.txt.template
  git rm generated_contributions.txt
  git commit generated_contributions.txt -m "Removes file" --date="$end_time +0100"

  # Completion
  printf "\nProcessing complete successfully!\n"
  printf "Please review the %d generated commits with 'git status' and 'git log --stat' before pushing the changes\n" "${num_commits}"

}

main() {
  if ((_PRINT_HELP))
  then
    print_help
  else
    process "$@"
  fi
}

# MAIN
main "$@"

