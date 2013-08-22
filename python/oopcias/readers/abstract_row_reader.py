
class AbstractRowReader: 

  #Indicates whether the resource has completed reading
  # the resource or not.
  # [In the case of streams we may not be done, but may also not
  #  have any more data to process]
  def isDone():
    return True

  #Indicates whether the resource is ready to read or not.
  # (E.g. with a streaming API)
  def hasMoreData():
    return False

  def nextRow():
    return []

## Definition of a Row Result
#
# A row will be a dictionary that has at the minimum the following:
# meta-data for each row:
#
# sourceKey: <some id>  #assumedly unique
# rowNumber: 0          # a postively increasing number
# numberColumns: <N>    # a positive number indicating the number of columns returned.
# keyOrder: [<key1>...] or None  # the key order of the 
# rowData: {
#   <key>:   <value>    #Values may be arrays, dictionaries, or simple character types
#   <key2> : <value2>
# }
#