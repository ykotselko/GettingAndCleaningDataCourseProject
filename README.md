### Introduction

The repository contains `run_analysis.R` script used to prepare tidy data that can be used for later analysis. 
It requires the "Human Activity Recognition Using Smartphones Dataset" to be downloaded and decompressed into working directory. 
The result of the script is a tidy dataset based on manipulation with data provided by "Human Activity Recognition Using Smartphones Dataset". 
The `CodeBook.md` file describes the variables, the data and transformations utilized by `run_analysis.R` script in order to clean up data and get the result.

### How it works
The prerequisite are:

1. copy `run_analysis.R` into working directory or set working directory to the folder where `run_analysis.R` is located;
2. download and decompress the "Human Activity Recognition Using Smartphones Dataset" ( https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ) into working directory;

As soon as it is done, `run_analysis.R` script could be executed using source("./run_analysis.R")
Result of the script is a `result_tidy_set.txt` file located in the working directory. 

## Script details
Script was created in order to complete assignment and consists of 5 steps as per assignment tasks.
First of all script checks either `UCI HAR Dataset` folder exists in working directory. Afterwards it loads features data set from `features.txt`, activity_labels set from `activitu_labels.txt` and adjust column names.

#Task 1. Merges the training and the test sets to create one data set.
At first script loads train data (x_train, y_train and subject_train) and merge them into train_set using cbind function. 
Next Script loads test data (x_test, y_tst and subject_test) and merge them into test_set using `cbind` function. 
Afterwards script merges (union) both train_srt and test_set using `rbind` function. 

#Task 2. Extracts only the measurements on the mean and standard deviation for each measurement.
In order to extract only measurement on the mean abs standard deviation we have to use grep function over list of features: grep("mean[(+]|std[(+]",features$Feature)+2)
And we have to subset the result set we got in previous step keeping in mind that we have to additional fields Subject_Id and Activiti_Id:
	mean_std_set <- result_set[,c(1,2,grep("mean[(+]|std[(+]",features$Feature)+2)]

#Task 3. Uses descriptive activity names to name the activities in the data set    
We have to merge mean_std_set with activity_labels set by "Activity_id"
mean_std_with_activity_names_set contains one more additional columns called "Activity" representing activity label
    mean_std_with_activity_names_set <- merge(activity_labels,mean_std_set,by = "Activity_Id")
    mean_std_with_activity_names_set$Activity_Id <- NULL

#Task 4. Appropriately labels the data set with descriptive variable names.
We can get the names of features using the following code: `grep("mean[(+]|std[(+]",features$Feature,value=TRUE)`
Now we need to play with it in order to give them the descriptive names
What we can do: 
       1. replace leading "t" with "time"
       2. replace leading "f"  with "frequency frequency-signal"
       3. replace "Acc" with "Accelerometer"
       4. replace "Gyro" with "Gyroscope"
       5. replace "Mag" with "Magnitude"
       6. remove ()
       and much more
the variable names will look like: time-Body-Accelerometer-mean-X or frequency-signal-BodyBody-Gyroscope-Magnitude-std, etc. 
    
we just have to compile vector of names and do not forget Activity and Subject_id collumns
    names(mean_std_with_activity_names_set) <- c("Activity", "Subject_Id", sub("Jerk","-Jerk",sub("[(][)]","",sub("Acc","-Accelerometer",sub("Gyro","-Gyroscope",sub("Mag","-Magnitude",sub("^t","time-",sub("^f","frequency-signal-",grep("mean[(+]|std[(+]",features$Feature,value=TRUE)))))))))

#Task 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
summarise_each function from dplyr package is the most suitable to group and computa averages
so, we load dplyr library, and use group_by and summarise_each function to get a averages
	    group_by_activity_and_subject_id <-group_by(mean_std_with_activity_names_set,Activity,Subject_Id)
	    result_set <- summarise_each(group_by_activity_and_subject_id,funs(mean))

Afterwards, we need to create a `tidy` data set. We use `tidyr` library and `gather` function:
	result_tidy_set <- gather(result_set,Feature, Mean,`time-Body-Accelerometer-mean-X`:`frequency-signal-BodyBody-Gyroscope-Jerk-Magnitude-std`, factor_key = TRUE)	

Done. Now we just have to write tidy data set into the file:
	write.table(result_tidy_set, file = "./result_tidy_set.txt", row.names = FALSE)




















