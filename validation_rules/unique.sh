#!/bin/bash


table_name=$1
argument=$2
column=$3
value=$4

table_data_file="./tables/${table_name}.txt"

if grep -q "|${column}:${value}|" "$table_data_file"; then
  echo "Column '${column}' must be unique."
else
  echo "None"
fi

exit 0