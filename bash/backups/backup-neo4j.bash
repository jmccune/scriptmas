
#!/bin/bash
# -- backup.bash -- 
#  This is a general protocol for backing things up
#  I have a central backup directory.
#  Originally written for my neo4j project, this could be 
#  a MYSQL or mongo db as in other projects I've done.
#

# ===================================================================
# CONFIGURATION 
# ===================================================================

BACKUPS_DIR="$HOME/.backups"
DB_TYPE="neo4j"
DATE_FOLDER=$(date +'%Y-%m-%d-%k')

BACKUP_FOLDER="$BACKUPS_DIR/$DB_TYPE/$DATE_FOLDER/"
PREVIOUS_BACKUP="$BACKUP_FOLDER/graph.db"


# ===================================================================
# INCLUDES
# ===================================================================
script_dir="$(dirname "$0")"
source "$script_dir/util.bash"

# ===================================================================
# MAIN
# ===================================================================
ensurePath $BACKUP_FOLDER

# Delete any previous backup the same hour...
if [[ -d "$PREVIOUS_BACKUP" ]]; then
	echo "Removing previous backup..."
	rm -r "$PREVIOUS_BACKUP"
fi

echo "BACKING UP THE NEO4J DATAFILE TO: $BACKUP_FOLDER"
cp  -r "$NEO4J_DATA/graph.db" "$BACKUP_FOLDER"

