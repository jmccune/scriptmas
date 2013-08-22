
import sys
import json

from  oopcias.readers.csv_row_reader import *

def matches(key,value,matchKey):
  return ((key == matchKey) and (len(value)>0))


matchKeys={'Action (action)':'action',
           'Sending Widget': 'sendingWidget',
           'Comments':'description'}

if __name__ == '__main__':
    numArgs = len(sys.argv)

    print('Number Arguments: ',numArgs, 'arguments')
    if (len(sys.argv)<2):
        print('Usage: ',sys.argv[0],' <filename>')
        sys.exit(1)
    print("Will RUN!")
    rowReader = CsvRowReader(sys.argv[1])

    newResultMap = {}
    while (rowReader.hasMoreData()):

        newResult = {}
        rowInfo = rowReader.nextRow()
        rowData = rowInfo['rowData']
        #print("ROW: ",rowInfo['rowNumber'])        
        #print("JSON",json.dumps(rowData))
        foundCount=0
        for key in rowData:
          value = rowData[key]
          for matchKey,newKey in matchKeys.items():
            if (matches(key,value,matchKey)):
              foundCount=foundCount+1
              newResult[newKey] = value
        #for key,value in rowInfo['rowData']:
        #  print('  >>  Key: ',key,'  value: ',value)
        if (foundCount>2):
          print(' Add: ',json.dumps(newResult))
          newResultMap[newResult['action']] = newResult

    #CONVERT TO ARRAY
    finalResult = []
    for key,value in newResultMap.items():
      finalResult.append(value)

    print('FINAL OUTPUT:')
    print(json.dumps(finalResult))
    
