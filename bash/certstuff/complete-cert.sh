#!/bin/bash

# CONFIGURATION
#-------------------------------
START_DIR="signedcert"
PEM_DIR="pem-certs"
P12_DIR="p12-certs"
JKS_DIR="jks-certs"
REQ_DIR="certrequest"
CACERT_DIR="."

#use the given file for the password.
# (For security, delete the file when you're done)
PASSWORD_FILE="certPasswordFile"
PASSWORD_SPEC="file:certPasswordFile"

#For security this password is read from the certPasswordFile
JKS_PASSWORD="<READ_FROM_THE_PASSWORD_FILE>"


CACERT_FILEPATH="$CACERT_DIR/cacerts.pem"

# HELPER
#-------------------------------
# trace/debugging utilities
# .. <Command> [<arg1> [<arg2> [.. <argN>]]]
# will ECHO the command for the user to see what is being run (As it executes it)
#
function ..() { echo "    $@" 1>&2; eval "$@"; }




# USAGE:
#-------------------------------
if [ "$#" -lt 1 ]; then
   echo " "
   echo "Usage: $0 $START_DIR/<cert-filename.cer(s)>"
   echo " This command will take the file(s) listed from the given input directory ($START_DIR)"
   echo " and run them through the transformation process, creating the"
   echo " directories (if needed):   $PEM_DIR, $P12_DIR, and $JKS_DIR   "
   echo " " 
   echo " In each of those directories will be the certificate in the "
   echo " desired format, named corresponding to the filename in the input directory."
   echo " "
   echo " For example, if you typed:  $0 $START_DIR/MyCert.cer  "
   echo " This command would attempt to generate: "
   echo "    +  $PEM_DIR/MyCert.pem "
   echo "    +  $P12_DIR/MyCert.pfx "
   echo "    +  $JKS_DIR/MyCert.jks " 
   echo " "
   echo " NOTE: This script will stop at the very first error."
   echo " "
   exit -1
fi

# Directory Creation (as needed)
#-------------------------------

# Create Directories (if they don't already exist)
requiredDirs=( "$PEM_DIR" "$P12_DIR" "$JKS_DIR" )
for dir in "${requiredDirs[@]}"
do
   if [ ! -d "$dir" ]; then
      echo " $dir  >> DIRECTORY DOES NOT EXIST >> will create"
      mkdir $dir 
   fi
done



# Main Argument Loop Function
#-------------------------------

processEachArg () {

  #echo "Parameter #1 is $1"
  #echo "Parameter #2 is $2"
  args=$1 
  echo " "
  echo "Processing ${#args[@]} files through step... "
  for filePath in "${args[@]}" 
  do	
     #Split the argument into it's component parts
     dir_file_extension=`echo "$filePath" | sed 's/\(.*\)\/\(.*\)\.\(.*\)/\1 \2 \3/' `
     array=($dir_file_extension)

     indir="${array[0]}"
     filename="${array[1]}"
     extension="${array[2]}"

     #Invoke the processor function $2
     # giving it the arguments it needs

     #Note: This actually runs the command 

     $2 $filePath $indir $filename $extension 
     
  done

}

#The below 10 function lines are the template for the processor Function
# to be run through the above processEachArg function.
#
processorFnTemplate() {
   filePath=$1
   indir=$2
   filename=$3
   extension=$4

   echo "  FullPath : $filePath "
   echo "  Processing: $indir    $filename      $extension "

}


#THE ARGUMENTS FROM THE COMMAND LINE
args=("$@")


# Below the function is declared and then
# run through the processEachArg function above
# following the below example:
#
#       processEachArg $args processorFnTemplate 
#



# Validation
#-------------------------------

echo "Validating... "

#Verify that the CACERTS file exists
if [ ! -f "$CACERT_FILEPATH" ]; then
   echo "    $CACERT_FILEPATH does not exist!"
   echo "    You must have the CA Certificates or you will not have a valid certificate chain." 
   echo "    Aborting run..."
   exit -1
fi

#Verify that the PASSWORD file exists
if [ ! -f "$PASSWORD_FILE" ]; then
   echo "    $PASSWORD_FILE does not exist!"
   echo "    You must have the password file, whose first line specifies the password to use."
   echo "    This password is used for extracting the password and storing the password in JKS."
   echo "    You should delete the password file once done creating your certs."
   echo "    Aborting run..."
   exit -1
fi

JKS_PASSWORD=$( cat $PASSWORD_FILE )
#echo "JKS_PASSWORD is: >>>$JKS_PASSWORD<<<"


argumentValidationFn() {
   filePath=$1
   indir=$2
   filename=$3
   extension=$4

   echo "  Validating : $filePath "

   #Verify that the file exists
   if [ ! -f "$filePath" ]; then
	echo "    $filePath does not exist!"
	echo "    Aborting run..."
	exit -1
   fi

   #Verify that the files are where we expect them to be to start.
   if [ "$START_DIR" != "$indir" ]; then
	echo "    $filePath is not in the correct start directory($START_DIR). Please correct."
	echo "    Aborting run..."
	exit -1
   fi

   #Verify that we are starting with the DER encoded certificate.
   if [ "cer" != "$extension" ]; then
	echo "    $filePath is not a certificate?  Wrong extension. "
	echo "    Aborting run..."
	exit -1
   fi

   #Verify that the PRIVATE key exists from the ORIGINAL request
   keyfile="$REQ_DIR/$filename.key.pem" 
   if [ ! -f "$keyfile" ]; then
	echo "    $keyfile  not found!!! This file must exist for this to work."
	echo "    Aborting run..."
	exit -1
   fi
   return 0
}

processEachArg $args argumentValidationFn




# CONVERT TO PEM
# STEP 1 of CertGen
#-------------------------------
convertToPEM() {
   filePath=$1
   indir=$2
   filename=$3
   extension=$4

   echo "  Processing: $filename --> CER  to  PEM"

   .. openssl x509 -in $indir/$filename.$extension -inform DER -out $PEM_DIR/$filename.pem
}

processEachArg $args convertToPEM


# CONVERT TO P12
# STEP 2 of CertGen
# Depends on STEP 1
#-------------------------------
convertToP12() {
   filePath=$1
   indir=$2
   filename=$3
   extension=$4

   echo "  Processing: $filename  --> PEM to P12" 

   .. openssl pkcs12 -export -out $P12_DIR/$filename.pfx -inkey $REQ_DIR/$filename.key.pem -in $PEM_DIR/$filename.pem -chain -CAfile $CACERT_FILEPATH -password "$PASSWORD_SPEC"

}

processEachArg $args convertToP12


# CONVERT TO JKS
# STEP 3 of CertGen
# Depends on Step 2
#-------------------------------
convertToJKS() {
   filePath=$1
   indir=$2
   filename=$3
   extension=$4

   echo "  Processing: $filename  --> P12 to JKS" 

   #NOTE: This keytool command cannot be echoded like the others
   #-- because the quoted password gets messed up
   #-- we don't want to echo the password anyway.
   echo "Generating keystore from $P12_DIR/$filename.pfx and storing in $JKS_DIR/$filename.jks"
   keytool -importkeystore -srckeystore $P12_DIR/$filename.pfx -srcstoretype pkcs12 -destkeystore $JKS_DIR/$filename.jks -deststoretype JKS -deststorepass "$JKS_PASSWORD" -srcstorepass "$JKS_PASSWORD"
}


processEachArg $args convertToJKS
# END  (FIN) 
#-------------------------------
echo " "
echo " "
echo "SUCCESSFULLY COMPLETED $0  !!!!"
