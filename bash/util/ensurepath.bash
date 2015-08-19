#!/bin/bash
# -- ensurepath.bash -- 
# A utiltiy to ensure that all the directories exist on a particular path.

_ep_addPath_result=''
function _ep_addPath {
	dirPath=$1
	dirElement=$2

    if [ -n "$dirPath" ]; then
		dirPath="$dirPath/$dirElement"
	else 
		dirPath="/$dirElement"
	fi

	#echo "CHECKING: $dirPath"

	if ! [[ -d "$dirPath" ]]; then
		test=$(mkdir "$dirPath")
	#else
	#	echo "DIR $dirPath exists"	    		
	fi

	_ep_addPath_result="$dirPath"	
}

function ensurePath {
	MY_PATH=$1
	

	IFS_RESTORE="$IFS"	
	IFS="/"
	arrPATH="${MY_PATH[@]}"

	dirPath=""

	for x in $arrPATH
	do
		#echo "X is $x"
		#If the dirElement is defined...
	    if [ -n "$dirElement" ]; then 
	    	_ep_addPath "$dirPath" "$dirElement"	    	
	    	dirPath="$_ep_addPath_result"	    	
	    fi
	    dirElement="$x"	  
	done	

	#Check to see if last element is a path or not...
	i=$((${#MY_PATH}-1))
	lastChar="${MY_PATH:$i:1}"

	if [[ "$lastChar" = "/" ]]; then		
		_ep_addPath "$dirPath" "$dirElement"		
	fi

	#Reset dirElement for future passes...
	dirElement=""	

}


function testEnsurePath {
	ensurePath "/Users/mccune/tmp/foo/bar"
	ensurePath "/Users/mccune/tmp/doh/dum/de2/dum2/"
}

#testEnsurePath
