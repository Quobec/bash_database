#!/bin/bash

table_name=$1
argument=$2 
column=$3
value=$4

table_data_file="./tables/${table_name}.txt"

char_count=${#value}

# I had to trim whitespaces
char_count="${char_count//[[:space:]]/}"
argument="${argument//[[:space:]]/}"

if (("$char_count" >= "$argument")); then
  echo "None" 
else
  # Idk whats wrong here. Problem arises when there are 2 arugments in echoed string. script by itself outputs correctly but output read in database.sh is wrong
  # It fixed itself after i trimmed whitespaces. ??????
  echo "Field '${column}' must have at least ${argument} characters."
fi

exit 0
