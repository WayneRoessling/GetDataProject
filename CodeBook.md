# GetDataProject
The data for this project is divided into two major sets of data.  The Training data set and the test data set.  These two sets are merged into one large set.  These sets have the same number of Variables for the measured values making the merge straight forward.

The Training and Test data entries are catagorized by the subject (person excuting activity) and the activity (walking, ect..) the subject was doing  during the measurement. 

The feature or measurement description/label was set on file dataload from the file using col.names parameter of read.table.  This was done for the Test and Training datasets as they were loaded into the data frames.  

The activity and subject information was added to the data frame as columns.  This associated each measurement with its appropriate Subject and Activity.  Subject and Activty values were taken from the apropriate tables and then matched to the correspomding rows of the measurement data. Activities were added as human readable strings, and Subjects were add as integers as the human names were not available.  

To minimize the memory utilization during the merge the unwanted features/columns were removed from measurement tables before the merge. The Standard deviation and Mean features/column were retained.  

To properly merge the data a unique rowid was set such that the merged data was easily tracked.  The unique id started on the Training data set then continued across the Test Data set.  The merge was then sorted on the unique rowid for easy comparison with the premerged data.

The output file for Steps 1-4 is called wearablemovementdata.txt.

Step 5 vreated a new data set that averaged each feature by Subject and Activity.  I decided use the same feature columns from wearablemovementdata and make the rows the averages by Subject then by Activity.  To make this data useful the rows are appropraietly labled.

Step 5 data set is called meanSubjectandActivity.txt


