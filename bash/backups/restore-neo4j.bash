#!/bin/bash
# -- restore-neo4j.bash -- 

# ===================================================================
# CONFIG
# ===================================================================
NEO4J_DB_DIR="$NEO4J_DATA/graph.db"
# ===================================================================
# MAIN
# ===================================================================


# --- Pre-condition/Argument Checking ---

if [ "$#" -ne 1 ]; then
   echo " "
   echo "Usage: $0 <backup-directory>"   
   echo " "
   echo " NOTE: The backup-directory is the DATE."
   echo " "
   exit -1
fi

if ! [[ -d "$1" ]]; then
	echo "Directory: $1 does not exist! Can't restore from there!"
	exit -1
fi

fullDir="$1/graph.db"
if ! [[ -d "$fullDir" ]]; then
	echo "Directory: $fullDir does not exist! Can't restore from there!"
	exit -1
fi


if ! [[ -d "$NEO4J_DATA" ]]; then
	echo "Target DB Directory: $NEO4J_DATA   doesn't exist???"
	exit -1
fi

# --- Execute the restore ---
echo "RESTORING the database from: $1 >> $fullDir"

# 1. Stop the DB
result=$(neo4j stop)
if [ $? -eq 0 ]; then
    echo "Neo4j Stopped"
else
    echo "FAILED to stop Neo4j?"
    exit -1
fi


#2. Remove the Database directory
if [[ -d "$NEO4J_DB_DIR" ]]; then 
	echo "Removing existing database..."
	rm -r "$NEO4J_DB_DIR"	
fi

echo "Copying the backup into place."
cp -r "$fullDir" "$NEO4J_DB_DIR"

echo "Backup Data Restored SUCCESSFULLY.  "
