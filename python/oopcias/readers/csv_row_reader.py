import sys
import os
import json

from  oopcias.readers.abstract_row_reader import *

class CsvRowReader(AbstractRowReader): 

    def __init__(self, filename, **options):

        print("Attempting to open file: "+filename)

        self.options = {'hasHeaders':True}
        self.options.update(options)
        self.filename = filename
        self.file = open(filename, 'r')

        #Always the next line of data to parse into a row result (or None on start).
        self.nextLine = None
        #The current result or None
        self.currentResult = None
        #The base meta-data (unchanging) and (changing: row number) 
        self.rowMetaData = None

        #Load the first line of the file. 
        self._readLine()

        
        


    #Indicates whether the resource has completed reading
    # the resource or not.
    # [In the case of streams we may not be done, but may also not
    #  have any more data to process]
    def isDone(self):
        return self.nextLine == ""

    #Indicates whether the resource is ready to read or not.
    # (E.g. with a streaming API)
    def hasMoreData(self):
        return not self.isDone()

    def nextRow(self):  
        self._readLine()      
        if (self.isDone()):
            self.file.close()
        return self.currentResult

    def _readLine(self):        
        #Note: This uses the nextLine, so leave here...
        self._processCurrentLine()
        
        #Advance to next
        self.nextLine = self.file.readline()


    #Takes the "nextLine" and makes it the "currentLine"
    # processing it into data.
    def _processCurrentLine(self):

        # If very first iteration, skip.
        if (self.nextLine == None):
            return None

        #If we haven't created the row meta-data, 
        # we can create it now that there is possible source for headers 
        # (assuming we're supposed to use them)
        if (self.rowMetaData == None):
            self.rowMetaData = {
                    'rowNumber':-1,
                    'numberColumns':None,
                    'sourceKey': self.filename             
                }
            if (self.options['hasHeaders']):
                self.rowMetaData['headers'] = self._parseLine(self.nextLine)
                self.nextLine = self.file.readline()
            else:
                self.rowMetaData['headers'] = []

        #INCREMENT for next pass...
        self.rowMetaData['rowNumber'] = self.rowMetaData['rowNumber']+1


        # === READ LINE ===
        rawRowData = self._parseLine(self.nextLine)

        # === PROCESS THE CURRENT LINE ===

        #Create the basic Result object based on the meta-data.
        currentResult = {}
        currentResult.update(self.rowMetaData)

        # Convert the data into a dictionary
        # Noting the original ordering
        headers = self.rowMetaData['headers']
        numHeaders = len(headers)
        numColumns = len(rawRowData)
        rowData ={}
        keyOrder=[]
        #Always process the particular rows number of columns
        # it may differ from the number of headers...
        for index in range(numColumns):
            #Prefer the proper header name if it exists...
            if (index<numHeaders):
                keyName = headers[index]                
            else:
                keyName = 'column'+str(index)
            value   = rawRowData[index]
            rowData[keyName] = value
            keyOrder.append(keyName)

        
        #Update the Resutl Object
        currentResult['numberColumns']=numColumns
        currentResult['keyOrder'] = keyOrder
        currentResult['rowData']  = rowData

        self.currentResult = currentResult


    def _parseLine(self, line):
        result = line.split(',')
        for index in range(len(result)):
            result[index] = result[index].strip()            
        return result



if __name__ == '__main__':
    numArgs = len(sys.argv)

    print('Number Arguments: ',numArgs, 'arguments')
    if (len(sys.argv)<2):
        print('Usage: ',sys.argv[0],' <filename>')
        sys.exit(1)
    print("Will RUN!")
    rowReader = CsvRowReader(sys.argv[1])
    while (rowReader.hasMoreData()):
        result = rowReader.nextRow()
        print("RESULT: ",json.dumps(result),"\n")