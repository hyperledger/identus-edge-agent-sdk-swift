#!/bin/bash

# Create the output directory if it doesn't exist
mkdir -p "Documentation/"

# Find all subfolders in the current directory and loop through them
find AtalaPrismSDK -type d | while read dir
do
  # Check if the folder name contains ".docc"
  if [[ "$dir" == *".docc"* ]]
  then
   # Copy .md files if they exist
    if [ -n "$(find "$dir" -maxdepth 1 -name '*.md' -print -quit)" ]
    then
      cp -p "$dir"/*.md "Documentation/"
    fi
    
    # Copy .png files if they exist
    if [ -n "$(find "$dir" -maxdepth 1 -name '*.png' -print -quit)" ]
    then
      cp -p "$dir"/*.png "Documentation/"
    fi
  fi
done
