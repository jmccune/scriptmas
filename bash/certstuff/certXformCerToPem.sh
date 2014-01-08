#!/bin/bash


if [ "$#" -lt 1 ]; then
   echo "Usage: $0 <cert-filename.cer(s)>"
   echo "Where the cert-filename.cer(s) are assumed to be located in a directory"
   echo "one level down from the current directory.   E.g. that the command is "
   echo "being run in <dir>  and that there is a <dir>/certs directory and     "
   echo "an implicit <dir>/xform directory."
   echo " "
   echo "Example:  certXformCerToPem.sh in/*.cer "
   exit -1
fi

args=("$@")
for i in "${args[@]}"
do
   #Break apart the argument in/*.cer   
   dir_file_extension=`echo "$i" | sed 's/\(.*\)\/\(.*\)\.\(.*\)/\1 \2 \3/' `
   array=($dir_file_extension)
 
   #indir= echo  "${array[0]}"
   #filename=  echo "${array[1]}"
   #extension=  echo "${array[2]}"

   indir="${array[0]}"
   filename="${array[1]}"
   extension="${array[2]}"
   
   echo "RUNNING COMMAND>> openssl x509 -in $indir/$filename.$extension -inform DER -out xform/$filename.pem -outform PEM" 
   $( openssl x509 -in $indir/$filename.$extension -inform DER -out xform/$filename.pem -outform PEM )
   #$( openssl x509 -in $i  -inform DER -out "$i.pem" -outform PEM )
done