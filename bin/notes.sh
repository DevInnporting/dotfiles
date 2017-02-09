#!/bin/bash

# useful colored output commands
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
bold=`tput bold`

function usage {
  echo "${bold}Usage: `basename $0` [-h|--help] [COMMAND]${reset}"
  echo ""
  echo "  Utility to search, create, delete and edit notes on bibliographic references,"
  echo "  where the notes are located under a predefined directory, specified in"
  echo "  the configuratoin file: $configFile"
  echo ""
  echo " COMMANDS"
  echo "    ${bold}search${reset} SEARCH_STRING"
  echo "        Searches for SEARCH_STRING in all the notes"
  echo "    ${bold}list${reset}"
  echo "        Lists all the notes files and the configured directory"
  echo "    ${bold}create${reset}"
  echo "        Creates a new file in the configured directory"
  echo "    ${bold}open|edit${reset} NOTE"
  echo "        Opens the specified NOTE text file in an editor"
  echo "    ${bold}delete${reset} NOTE"
  echo "        Deletes the specified NOTE text file"
  echo " OPTIONS"
  echo "    ${bold}-h|--help${reset}"
  echo "        Displays this usage page and exits"
  exit 1
}

function echoNotesDir {
  echo "Using notes directory: ${bold}$notesDir${reset}"
}

function listNotes {
  echoNotesDir
  ls -1 $notesDir
}

function createNote {
  echoNotesDir
  read -p "Enter a name for the new note (without extension): " noteName
	echo ""
  gedit "$notesDir/$noteName.txt" &
}

function searchNotes {
  echoNotesDir
  grep --color=always -nwi $notesDir/*.txt -e "$1" | sed 's|^.*/||g'
}

function checkNote {
  if [[ -z "$1" ]]; then
    echo "Error: please provide a NOTE filename (with extension and without parent path)."
    exit 1
  fi
  if [[ ! -f "$notesDir/$1" ]]; then
    echo "Error: note $1 does not exist or is not a regular file."
    exit 1
  fi
}

function openNote {
  checkNote "$1"
  gedit "$notesDir/$1" &
}

function deleteNote {
  checkNote "$1"
  read -p "This will delete $1. Continue? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm "$notesDir/$1"
  fi
}

# check for root
if [[ $(id -u) -ne 0 ]]; then
  # load config
  configFile="$HOME/.notes.cfg"
  source $configFile

  # help: usage + exit
  if [[ "$#" = "0" || "$1" = "--help" || "$1" = "-h" ]]; then
    usage
  fi

  # select the command
  if [[ "$1" = "search" ]]; then
    shift
    searchNotes "$@"
  elif [[ "$1" = "list" ]]; then
    listNotes
  elif [[ "$1" = "create" ]]; then
    createNote
  elif [[ "$1" = "open" || "$1" = "edit" ]]; then
    shift
    openNote "$@"
  elif [[ "$1" = "delete" ]]; then
    shift
    deleteNote "$@"
  else
    echo "Error: command not recognised: $1"
  fi
else
  echo "Error: this script should NOT be run as root."
  exit 1
fi