#!/bin/bash

# CONFIGURATION
#-------------------------------
REQ_DIR="certrequest"
SIGNED_CERT_DIR="signedcert"

# HELPER
#-------------------------------
# trace/debugging utilities
# .. <Command> [<arg1> [<arg2> [.. <argN>]]]
# will ECHO the command for the user to see what is being run (As it executes it)
#
function ..() { echo "    $@" 1>&2; eval "$@"; }

#USAGE
if [ "$#" -lt 2 ]; then
   echo "Usage: $0 <certname> <subject>"
   echo " "
   echo " Generates a certificate request for the certificate indicated."
   echo " Subject is a standard certificate subject. "
   echo " Example usage: "
   echo "     $0  testuser2 /DC=com/DC=yourdomain/CN=Users/CN=testuser2/  "
   echo " "
   echo " Be careful of spaces in the 2nd argument -- use \\ to escape as needed."
   echo "  "
   echo " The example above would create the testuser2.key.pem file in the $REQ_DIR directory"
   echo " as well as the testuser2.req.pem.   The testuser2.req.pem is the actual request "
   echo " the key.pem file is the Private Key that is held/saved for a later step. "
   echo " The certificate signing request (req.pem) is then used to get the certificate " 
   echo " authority to sign the request. "
   echo " "
   echo " After the resulting request is signed, the correspondingly named cer file "
   echo " (in the example, this would be testuser2.cer) should be placed in the  "
   echo " $SIGNED_CERT_DIR directory (for signed certificates.)"
   echo " "  
   exit -1
fi



# Directory Creation (as needed)
#-------------------------------

# Create Directories (if they don't already exist)
requiredDirs=( "$REQ_DIR" "$SIGNED_CERT_DIR" )
for dir in "${requiredDirs[@]}"
do
   if [ ! -d "$dir" ]; then
      echo " $dir  >> DIRECTORY DOES NOT EXIST >> will create"
      mkdir $dir
   fi
done


# Request & Private Key Creation
#-------------------------------

private_key=$1.key.pem

echo "private key is: $private_key"
echo "subject will be: $2"

.. openssl genrsa -out $private_key 2048 
.. openssl req -new -key $private_key -out $1.req.pem -outform PEM -subj "$2" -nodes 

mv $1.req.pem $REQ_DIR
mv $1.key.pem $REQ_DIR

echo "Below is your certificate:"
cat $REQ_DIR/$1.req.pem

echo " "
echo " Use this to get a SIGNED certificate request (.CER) file. "
echo " That file should be named: $1.cer "
echo " And then be placed here:  $SIGNED_CERT_DIR "
