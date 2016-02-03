# Data sets ae saved in different files. 
#Also columns names and activity and subjects are in other files.
# we have to merge all of then into a single dataset with meaingfull names.
#Then the required data will be extracted.
##load required packages
library(data.table)
library(dplyr)
library(plyr)

##load lables and extract the values related to mean ans std
featureName <- read.table("./UCI HAR Dataset/features.txt", colClasses = "character" )
featureNameMeanStd <- grep(".*(mean|std).*", featureName$V2)

##load activities labels and names
activity <- read.table(".//UCI HAR Dataset/activity_labels.txt")
names(activity) <- c("ActivityLable", "ActivityName")

##Load test data
###set
testset <- read.table(".//UCI HAR Dataset/test/X_test.txt")
colnames(testset) <- featureName$V2
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
head(testsub)
###merging all test data
list <- list(testsub,testact,testset)
testset <- join_all(list)
testset <- full_join(activity, testset)
testset <- arrange(testset,id)
testgood <- testset[,c(1:4, featureNameMeanStd+4)]
names(testgood) <- c(names(testgood)[1:4], featureName$V2[featureNameMeanStd])
dim(testgood)
head(testgood)
