#!/bin/sh

modify_project () {
  PROJECT=$1
  [ "$PROJECT" == "" ] && help_project && exit
  [ "$(uname -s)" == "Darwin" ] && open ~/.projx/$PROJECT.sh || vi ~/.projx/$PROJECT.sh
}
