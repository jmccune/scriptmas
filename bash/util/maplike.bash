#!/bin/bash

#NOTE:  Spaces are ignored
#       ":" must be the separator between the key and the value.
#       (e.g. the key cannot contain a :)
kvmap[0]="a:a1"
kvmap[1]="a:a2"
kvmap[2]="b:b1"
kvmap[5]="c:c1"


processEachMapArg() {
  
  declare -a args=("${!1}")
  echo "Will Process key/value pairs: ${args[@]}"  
  echo "Processing ${#args[@]} arg... "
  for arg in "${args[@]}" 
  do  
     #Split the argument into it's component parts
     dir_file_extension=`echo "$arg" | sed 's/\(.*\)\:\(.*\)/\1 \2/' `
     array=($dir_file_extension)

     key="${array[0]}"
     value="${array[1]}"
     echo "KEY: $key   --> Value: $value"

  done
}

echo "TEST ARRAY IS: ${kvmap[@]}"

processEachMapArg kvmap[@]

