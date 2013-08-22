import json
import sys
import os

def writeFile(filePath, content):
  
  f = open(filePath, 'w')
  f.write(content)
  f.close()




def makeNewFilename(url):      
  result =''
  for i in range(0,len(url)):
    ch = url[i]
    if (ch.isalnum() or ch=='.'):
      result = result + ch
    else:
      if (len(result)>0 and result[-1:]!='-'):
        result = result + '-'
    #else:
      #print 'CH: '+ch+ ' is not alphanumeric'  
  return result
  



def processHarFile(filename,targetDir):    
  myfile = json.loads(open(filename).read())

  print "READ FILENAME: "+filename
  #print myfile
  for entry in myfile['log']['entries']:

    url = entry['request']['url']
    print " =========================================="
    print "URL: "+url
    print " =========================================="
    print " ------------------------------------------"
    response = entry['response']

    responseFile = response['content']['text']
    responseFile = responseFile.encode("utf-8")
    responseFile = str(responseFile)

    if (len(responseFile)>512):
      partA = responseFile[0:250]
      partB = responseFile[-250:]
      
      print partA+ '\n     . . .     \n'+partB
    else:
      print responseFile

    print " ------------------------------------------"
    print " =========================================="

    newFilename = makeNewFilename(url)
    filePath = os.path.join(targetDir,newFilename)
    print " Writing >> "+filePath

    writeFile(filePath,responseFile)
    print "\n\n"

  print "\n\n"
  print "COMPLETED PROCESSING OF FILENAME: "+filename

if __name__ == '__main__':
    numArgs = len(sys.argv)

    print 'Number Arguments: ',numArgs, 'arguments'
    if (len(sys.argv)<3):
        print 'Usage: ',sys.argv[0],' <filename.har> <targetDir>'        
        sys.exit(-1)

    targetDir = sys.argv[2]
    if (not os.path.exists(targetDir)):
      print 'Target directory: '+targetDir+' does not exist!'
      sys.exit(-1)

    processHarFile(sys.argv[1],targetDir)
