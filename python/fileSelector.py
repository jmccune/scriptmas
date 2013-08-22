#! /usr/bin/env python


import os
import sys
import re

from os.path import join, getsize


# Given a list of compiled regular expressions,
# determine if the filename contains the regular
# expression ANYWHERE in the filename.
def nameMatchesPatterns(compiledPatternList, filename):
    if (len(compiledPatternList)==0):
        return False

    for cre in compiledPatternList:
        #print 'TESTING: ',filename,' against ',str(cre)
        if (cre.search(filename)!=None):
            return True

    return False

#  Given a starting directory, recursively walk through 
#  all the files-- and include the file if it matches
#  an inclusion pattern (and does not match an exlcusion pattern).
#
#  Return a list of files that match the inclusion pattern 
#  & not the exclusion pattern
def getFileList(startDir,includePatterns,excludePatterns):
    mylist = []
    
    # ==== Argument Preprocessing 
    if (includePatterns is None):
        includePatterns  = ['.*']
    if (excludePatterns is None):
        excludePatterns = []

    # ==== Pattern Compilation
    compiledIncludePatterns = []
    compiledExcludePatterns = []

    for pattern in includePatterns:
        compiledIncludePatterns.append(re.compile(pattern))

    for pattern in excludePatterns:
        compiledExcludePatterns.append(re.compile(pattern))

    # ==== Filename Generation
    for root,dirs,files in os.walk(startDir):
        #print root, "consumes"
        for name in files:
            #print "   >>   ",join(root, name)
            filename = join(root,name)
            if (not nameMatchesPatterns(compiledIncludePatterns,filename)):
                continue
            #print "      Passed Include Filter"
            if (nameMatchesPatterns(compiledExcludePatterns,filename)):
                continue
            #print "      Passed Exclude Filter"
            mylist.append(filename)
        
    return mylist

if __name__ == '__main__':
    numArgs = len(sys.argv)

    print 'Number Arguments: ',numArgs, 'arguments'
    if (len(sys.argv)<2):
        print 'Usage: ',sys.argv[0],' <startdir> [ <includePattern1>  [ <includePattern2> ... ]]  [EXCLUDE <excludePattern1> [ <excludePattern2> ... ]]'
        print 'Example: ',sys.argv[0], '/my/dir/to/search/  ".*\.css" ".*\.py" EXCLUDE ".*\.bak\.py"'
        sys.exit(1)
    
    doingInclude = True

    if (numArgs>2):
        includePatterns = []
        excludePatterns = []
        for argNum in range(2,len(sys.argv)):

            if (sys.argv[argNum] == 'EXCLUDE'):
                doingInclude= False
                continue
            arg = sys.argv[argNum].replace('"','')

            if (doingInclude):
                includePatterns.append(arg)
            else:
                excludePatterns.append(arg)
    else:
        includePatterns = None
        excludePatterns = None

    print "EXCLUDE PATTERNS: "+str(excludePatterns)
    print "INCLUDE PATTERNS: "+str(includePatterns)

    mylist = getFileList(sys.argv[1], includePatterns ,excludePatterns)
    for filename in mylist:
        print " >FINAL SET> ",filename