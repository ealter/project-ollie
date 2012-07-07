#!/bin/bash

#Put the data you want in the file /tmp/dataInput.txt

function sendTouchInput() {
  folder="$@"
  folder=$(dirname "$folder")
  cd "$folder"
  cd ../Documents
  cat /tmp/dataInput.txt | grep -E 'circle|rect' > touchInput.txt
}

export -f sendTouchInput
find ~/Library/Application\ Support/iPhone\ Simulator -name ProjectOllie -exec bash -c 'sendTouchInput {}' \;

