#!/bin/bash
# -- drop-neo4j.bash --

# ===================================================================
# CONFIG
# ===================================================================
DB_DIR="$NEO4J_DATA/graph.db"

# ===================================================================
# MAIN
# ===================================================================

# --- Pre-condition/Argument Checking ---

if ! [[ -d "$DB_DIR" ]]; then
	echo "The directory doesn't exist already?!?!"
	exit 0
fi

# 1. Stop the DB
result=$(neo4j stop)
if [ $? -eq 0 ]; then
    echo "Neo4j Stopped"
else
    echo "FAILED to stop Neo4j?"
    exit -1
fi

#2 Drop the directory
rm -r "$DB_DIR"

echo "$DB_DIR was removed-- the neo4j database has no data. "
echo "If you want neo4j to run, you must restart it."