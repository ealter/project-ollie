#!/bin/bash
function removeTouchInput() {
  folder="$@"
  folder=$(dirname "$folder")
  cd "$folder"
  cd ../Documents
  rm -f touchInput.txt
}

export -f removeTouchInput
find ~/Library/Application\ Support/iPhone\ Simulator -name ProjectOllie -exec bash -c 'removeTouchInput {}' \;

