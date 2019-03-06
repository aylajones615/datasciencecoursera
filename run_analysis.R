
#load a package we need later
library(dplyr)

#read in data (NOTE! The file paths will need to be updated to point to wherever your downloaded data is stored)
features <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\features.txt', 
                       header = FALSE)

activity_labels <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\activity_labels.txt', 
                              header = FALSE)

x_train <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\train\\X_train.txt', 
                      header = F)

y_train <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\train\\y_train.txt', 
                      header = F)

subject_train <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\train\\subject_train.txt', 
                            header = FALSE)

x_test <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\test\\X_test.txt', 
                      header = F)

y_test <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\test\\y_test.txt', 
                      header = F)

subject_test <- read.table('C:\\Users\\U57A98\\Downloads\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\test\\subject_test.txt', 
                            header = FALSE)


#name the columns in activity_labels
names(activity_labels) <- c('activity_code', 'activity_description')

#remove the column with the feature codes, since we just need the actual feature names
features$V1 <- NULL

#convert the feature names to characters
features$V2 <- as.character(features$V2)

#transpose the dataset so that we can use the feature names as the column names in the training dataset
features <- t(features)

#append the training and test datasets together
x <- rbind(x_train, x_test)
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)

#rename the x dataset with the descriptions of each measurement from the features table
colnames(x) <- features

#rename the column in the subject data
names(subject) <- c('subject_code')

#rename the column in the y data
names(y) <- c('activity_code')

#merge the activity description based on its code
y <- merge(x = y, y = activity_labels, by = 'activity_code', all.x = TRUE)

#and get rid of the now unnecessary code column
y$activity_code <- NULL

#append the subject and activity code columns to the training dataset
data <- cbind(subject, y, x)

#filter the data to only include mean and stdev measurements
std_cols <- grep("std", colnames(data))
mean_cols <- grep("mean", colnames(data))

#searching for columns with "mean" also returns "meanfreq" columns, which we don't want
meanfreq_cols <- grep("Freq", colnames(data))
mean_cols <- mean_cols[!mean_cols %in% meanfreq_cols]

#select only the columns we need from the data
data <- data[, c(1:2, mean_cols, std_cols)]

#now get a separate dataset that summarizes the average value of each variable by each subject and activity combination
#append the word "average" to the end of each summarized variable so we'll know what the calculation is
summary_data <- data %>% group_by(subject_code, activity_description) %>%
                         summarise_all(funs(average = mean))

#now remove the unnecessary tables
rm(x_train, x_test, y_train, y_test, subject_train, subject_test, activity_labels, features, subject, x, y, 
   mean_cols, meanfreq_cols, std_cols)
