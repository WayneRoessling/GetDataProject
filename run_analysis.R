The data for this project is divided into two major sets of data.  The Training data set and the test data set.  
These two sets are merged into one large set.  These sets have the same number of Variables for the measured 
values making the merge straight forward.

The Training and Test data entries are catagorized by the subject (person excuting activity) and the activity 
(walking, ect..) the subject was doing  during the measurement. 

The feature or measurement description/label was set on file dataload from the file using col.names parameter 
of read.table.  This was done for the Test and Training datasets as they were loaded into data frames.  

The activity and subject information was added to the data frame as columns.  This associated each measurement 
with its appropriate Subject and Activity.  Subject and Activty values were taken from the apropriate tables 
and then matched to the correspomding rows of the measurement data.   

To minimize the memory utilization during the merge the unwanted features/columns were removed from measurement 
tables before the merge.

To properly merge the data a unique rowid was set such that the merged data was easily tracked.  The unique id 
started on the Training data set then continued accross the Test Data set.  The merge was then sorted on the 
unique rowid for easy comparison with the premerged data.

The output file for Steps 1-4 is called wearablemovementdata.txt.

fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "./proj1Dataset.zip")
unzip("./proj1Dataset.zip")

featuresdata <- read.table("./UCI HAR Dataset/features.txt", colClasses = "character")
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")


# Load Test Data
testXdata <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = featuresdata[[2]])
testYdata <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testsubjectdata <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Prepare Activity Label for asignment to the X Data Frame
activitylabelvector <- vector()
for (i in 1:length(testYdata[,"V1"])) {
    activitylabelvector[i] <- as.character(activity_labels[testYdata[i,"V1"],"V2"])
}

# Assign Acitity Variable and Subject Variable
testXdata$Activity <- activitylabelvector
testXdata$Subject <- testsubjectdata[,"V1"]


# Load Training Data
trainXdata <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = featuresdata[[2]])
trainYdata <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainsubjectdata <- read.table("./UCI HAR Dataset/train/subject_train.txt")


# Prepare Activity Label for asignment to the X Data Frame
activitylabelvector <- vector()
for (i in 1:length(trainYdata[,"V1"])) {
    activitylabelvector[i] <- as.character(activity_labels[trainYdata[i,"V1"],"V2"])
}

# Assign Acitity Variable and Subject Variable
trainXdata$Activity <- activitylabelvector
trainXdata$Subject <- trainsubjectdata[,"V1"]


#Clean up columns before merge
varnames <- names(trainXdata)
deletecolumnlist <- list()
deletecolumnindex <- 1
for (i in 1:(length(varnames)-2)) {
    if (length(grep("std",varnames[i])) + 
            length(grep("mean", varnames[i])) +
            length(grep("Mean", varnames[i])) == 0) {
        deletecolumnlist[deletecolumnindex] <- i;
        deletecolumnindex <- deletecolumnindex + 1
    }
}

deletecolumniterator = length(deletecolumnlist)

# delete the columns
while (deletecolumniterator > 0) {
    deletecolumnindex <- deletecolumnlist[[deletecolumniterator]]
    trainXdata[,deletecolumnindex] <- NULL
    deletecolumniterator = deletecolumniterator -1
}

varnames <- names(testXdata)
deletecolumnlist <- list()
deletecolumnindex <- 1
for (i in 1:(length(varnames)-2)) {
    if (length(grep("std",varnames[i])) + 
            length(grep("mean", varnames[i])) +
            length(grep("Mean", varnames[i])) == 0) {
        deletecolumnlist[deletecolumnindex] <- i;
        deletecolumnindex <- deletecolumnindex + 1
    }
}

deletecolumniterator = length(deletecolumnlist)

# delete the columns
while (deletecolumniterator > 0) {
    deletecolumnindex <- deletecolumnlist[[deletecolumniterator]]
    testXdata[,deletecolumnindex] <- NULL
    deletecolumniterator = deletecolumniterator -1
}

#cleanup memory
rm(featuresdata)
rm(activitylabelvector)
rm(activity_labels)
rm(trainYdata)
rm(testYdata)
rm(trainsubjectdata)
rm(testsubjectdata)

# Merge Test and Training data

# First assign unique rowids as merge key
trainXdata$UniqueRowid <- 1:length(trainXdata[,"Activity"])
testXdata$UniqueRowid <- length(trainXdata$UniqueRowid)+1:length(testXdata[,"Activity"])

# Merge data
tidydata <- merge(trainXdata, testXdata, all=TRUE)

#clean up memory
rm(trainXdata)
rm(testXdata)

#Order merged data on Unique Row Id
tidydata <- tidydata[order(tidydata$UniqueRowid),]

# Add Factors
tidydata$Activity <- factor(tidydata[,"Activity"])
tidydata$Subject <- factor(tidydata[,"Subject"])

write.table(tidydata, file = "./wearablemovementdata.txt", row.name=FALSE)


####################
#  Step 5
SubjectandActivity <- data.frame()

colnames <- names(tidydata)
Subjects <- unique(tidydata[,"Subject"])
Activity <- unique(tidydata[,"Activity"])
myrownames <- vector()

for (i in 1:(length(colnames)-3)) {
    #calculate Averages for each subject
    for (j in 1:(length(Subjects))) {
        SubjectandActivity[j,i] <- mean(tidydata[tidydata$Subject == Subjects[j],i])
        #print(c("Subject ",j, " column", i))
        myrownames[j] <- paste("Subject ",j)
    }
    #calculate AVerages for each Activity
    for (j in 1:(length(Activity))) {
        SubjectandActivity[length(Subjects) + j,i] <- mean(tidydata[tidydata$Activity == Activity[j],i])
        myrownames[length(Subjects) + j] <- paste("Activity ",Activity[j])
    }
}
names(SubjectandActivity) <-  colnames[1:length(SubjectandActivity)]
row.names(SubjectandActivity) <- myrownames

write.table(SubjectandActivity, file = "./meanSubjectandActivity.txt")
    
# ## Load interial signals
# testdataframelist <- list()
# traindataframelist <- list()
# filelistwpath = list.files(path = "./UCI HAR Dataset/test/Inertial Signals/",pattern="*.txt",full.names = TRUE)
# testfilelist = list.files(path = "./UCI HAR Dataset/test/Inertial Signals/",pattern="*.txt")
# 
# for (i in 1:length(testfilelist)) {
#     varname <- substr(testfilelist[i], 1, nchar(testfilelist[i]) - 4)
#     testdataframelist[i] <- assign(varname, read.table(filelistwpath[i]))
# }
# 
# filelistwpath = list.files(path = "./UCI HAR Dataset/train/Inertial Signals/",pattern="*.txt",full.names = TRUE)
# trainfilelist = list.files(path = "./UCI HAR Dataset/train/Inertial Signals/",pattern="*.txt")
# 
# for (i in 1:length(trainfilelist)) {
#     varname <- substr(trainfilelist[i], 1, nchar(trainfilelist[i]) - 4)
#     traindataframelist[i] <- assign(varname, read.table(filelistwpath[i]))
# }

# for (i in 1:length(traindataframelist)) {
#     mergedvarname <- substr(trainfilelist[i], 1, nchar(trainfilelist[i]) - 10)
#     assign(mergedvarname, merge(traindataframelist[i], testdataframelist[i] try no default merge))
# }
    

