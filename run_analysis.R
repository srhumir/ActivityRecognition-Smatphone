# Data sets ae saved in different files. 
#Also columns names and activity and subjects are in other files.
# we have to merge all of then into a single dataset with meaingfull names.
#Then the required data will be extracted.
##load required packages
library(dplyr)
library(plyr)

##load lables and extract the values related to mean ans std
featureName <- read.table("./UCI HAR Dataset/features.txt", colClasses = "character" )
##I noted an extra repeat in Body and removed it.
featureName$V2 <- gsub("BodyBody", "Body", featureName$V2)
featureNameMeanStd <- grep(".*(mean|std).*", featureName$V2)

##load activities labels and names
activity <- read.table(".//UCI HAR Dataset/activity_labels.txt")
names(activity) <- c("ActivityLable", "ActivityName")

##Loading and tidying up test data
###set
testset <- read.table(".//UCI HAR Dataset/test/X_test.txt")
testset <- mutate(testset, id = 1:length(testset$V1))
###activity
testact <- read.table(".//UCI HAR Dataset/test/y_test.txt")
testact <- as.data.frame(testact)
names(testact) <- "ActivityLable"
testact <- mutate(testact, id = 1:length(testact$ActivityLable))
###Subjects
testsub <- read.table(".//UCI HAR Dataset/test/subject_test.txt")
testsub <- as.data.frame(testsub)
names(testsub) <- "SubjectCode"
testsub <- mutate(testsub, id = 1:length(testsub$SubjectCode))
###merging all test data
list <- list(testsub,testact,testset)
testset <- join_all(list)
testset <- full_join(activity, testset)
testset <- arrange(testset,id)


##Loading and tidying up train data
###set
trainset <- read.table(".//UCI HAR Dataset/train/X_train.txt")
idvalue <- (length(testset$V1)+1):(length(testset$V1)+length(trainset$V1))
trainset <- mutate(trainset, id = idvalue)
###activity
trainact <- read.table(".//UCI HAR Dataset/train/y_train.txt")
trainact <- as.data.frame(trainact)
names(trainact) <- "ActivityLable"
trainact <- mutate(trainact, id = idvalue)
###Subjects
trainsub <- read.table(".//UCI HAR Dataset/train/subject_train.txt")
trainsub <- as.data.frame(trainsub)
names(trainsub) <- "SubjectCode"
trainsub <- mutate(trainsub, id = idvalue)
###merging all test data
list <- list(trainsub,trainact,trainset)
trainset <- join_all(list)
trainset <- full_join(activity, trainset)
trainset <- arrange(trainset,id)


##merging test and train data
alldata <- rbind(testset,trainset)

##Extracting only the measurements on the mean and standard deviation 
##for each measurement.
MeanStdData <- alldata[,c(1:4, featureNameMeanStd+4)]
names(MeanStdData) <- c(names(MeanStdData)[1:4], featureName$V2[featureNameMeanStd])
MeanStdData <- MeanStdData[,c(4,(1:ncol(MeanStdData))[-4])] #move id to first column

##write final dataset to file
###dataset file
write.table(MeanStdData, file = "./ActivityRecognition-Smatphone.txt", row.names = FALSE)
###feature file
write.table(cbind(1:length(featureNameMeanStd), featureName$V2[featureNameMeanStd]),
            file = "./smartphone/features.txt",
            row.names = FALSE, col.names = FALSE, quote = FALSE)
