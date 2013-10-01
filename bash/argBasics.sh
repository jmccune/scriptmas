#!/bin/bash

args=("$@")
echo "$# arguments were passed in"
echo "The args are: " 

for i in "${args[@]}"
do
   echo "   arg: $i "
done

if [ "$#" -lt 2 ]; then
   echo "Usage: $0 <arg0> <arg1>"
fi
