#0. Preparation steps:     
    
    samgung_data_folder = "./UCI HAR Dataset"
    
    #check Samsung data folder is in the working directory
    if (!file.exists(samgung_data_folder)) {
        stop("Samsung data not found.")
    }
    
    #loading features
    features <- read.table(paste0(samgung_data_folder,"./features.txt"),header = FALSE)
    #adjusting feature column names
    names(features) <- c("Feature_Id","Feature")
    
    #loading activity_labels
    activity_labels <- read.table(paste0(samgung_data_folder,"./activity_labels.txt"),header = FALSE)
    #adjusting column names
    names(activity_labels) <- c("Activity_Id","Activity")
    
#1. Merges the training and the test sets to create one data set.
    #loading training data
    
    #x_train data frame contains training set, each column represents appropriate feature
    x_train <- read.table(paste0(samgung_data_folder,"./train/X_train.txt"),header = FALSE)
    
    #y_train data set represent activity ids
    y_train <- read.table(paste0(samgung_data_folder,"./train/Y_train.txt"),header = FALSE)
    
    #changing columne name from V1 to Activity_Id for the y_train data set
    names(y_train) <- c("Activity_Id")
    
    subject_train <- read.table(paste0(samgung_data_folder,"./train/subject_train.txt"),header = FALSE)
    #changing columne name from V1 to Subject_Id for the subject_train data set
    names(subject_train) <- c("Subject_Id")
    
    #merge train data using cbind.
    #as a result we will have a 7352 x 563 set consisting of Subject_Id, Activity_id, and 561 V1 ... V561 columns
    train_set <-cbind(subject_train,y_train,x_train)
    
    
    #loading test data
    #x_test data frame contains training set, each column represents and activity 
    x_test <- read.table(paste0(samgung_data_folder,"./test/X_test.txt"),header = FALSE)
    
    #y_test data set represent activity ids
    y_test <- read.table(paste0(samgung_data_folder,"./test/Y_test.txt"),header = FALSE)
    #changing columne name from V1 to Activity_Id for the y_test data set
    names(y_test) <- c("Activity_Id")
    
    subject_test <- read.table(paste0(samgung_data_folder,"./test/subject_test.txt"),header = FALSE)
    #changing columne name from V1 to Subject_Id for the subject_test data set
    names(subject_test) <- c("Subject_Id")
    
    #merge train data using cbind. 
    #as a result we will have a 2947 x 563 set consisting of Subject_Id, Activity_id, and 561 V1 ... V561 columns
    test_set <-cbind(subject_test,y_test,x_test)
    
    #merge train and test sets
    #According to the README.txt: "The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data".
    #So, we need to merge test and train sets using rbind function (UNION in SQL terms)
    #The result set has a dimension of 10299 x 563 and contains both test and training data
    
    result_set <- rbind(train_set,test_set)
    
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
    
    #columns we need could be taken from features set using the following command: grep("mean[(+]|std[(+]",features$Feature)
    #in order to extract these columns from the result_set we need extract Subject_Id and Actrivity_Id as well as shift feature index by 2
    
    mean_std_set <- result_set[,c(1,2,grep("mean[(+]|std[(+]",features$Feature)+2)]
    #mean_std_set has 10299 x 68 dimension, consisting of Subject_Id, Activity_id, and 66 mean or std related features
    
    
#3. Uses descriptive activity names to name the activities in the data set
    #We have to merge mean_std_set with activity_labels set by "Activity_id"
    #mean_std_with_activity_names_set contains one more additional columns called "Activity" representing activity label
    mean_std_with_activity_names_set <- merge(activity_labels,mean_std_set,by = "Activity_Id")
    
    #We do not need Activity_id anymore, so let's drop it
    mean_std_with_activity_names_set$Activity_Id <- NULL
    
    
#4. Appropriately labels the data set with descriptive variable names.
    # we can get the names of features using the following code: grep("mean[(+]|std[(+]",features$Feature,value=TRUE)
    #now we need to play with it in order to give them the descriptive names
    # What we can do: 
    #   1. replace leading "t" with "time"
    #   2. replace leading "f"  with "frequency frequency-signal"
    #   3. replace "Acc" with "Accelerometer"
    #   4. replace "Gyro" with "Gyroscope"
    #   5. replace "Mag" with "Magnitude"
    #   6. remove ()
    #   and much more
    #   the varuiable names will look like: time-Body-Accelerometer-mean-X or frequency-signal-BodyBody-Gyroscope-Magnitude-std, etc. 
    
    #we just have to compile vector of names and do not forget Activity and Subject_id collumns
    names(mean_std_with_activity_names_set) <- c("Activity", "Subject_Id", sub("Jerk","-Jerk",sub("[(][)]","",sub("Acc","-Accelerometer",sub("Gyro","-Gyroscope",sub("Mag","-Magnitude",sub("^t","time-",sub("^f","frequency-signal-",grep("mean[(+]|std[(+]",features$Feature,value=TRUE)))))))))
    
    
#5.   From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    
    #summarise_each function from dplyr package is the most suitable to group and computa averages
    
    #so, we load dplyr library
    library(dplyr)
    
    #group mean_std_with_activity_names_set by Activity and Subject_Id
    group_by_activity_and_subject_id <-group_by(mean_std_with_activity_names_set,Activity,Subject_Id)
    
    #getting result_tidy_set using summarise_each function
    result_set <- summarise_each(group_by_activity_and_subject_id,funs(mean))
    
    #load tidyr library
    library(tidyr)
    
    #we use function gather from tidyr library to convert "horizontal" structure to "vertical" (wide to long)
    result_tidy_set <- gather(result_set,Feature, Mean,`time-Body-Accelerometer-mean-X`:`frequency-signal-BodyBody-Gyroscope-Jerk-Magnitude-std`, factor_key = TRUE)
    
    #write result_tidy_set into result_tidy_set.txt file in working directory
    write.table(result_tidy_set, file = "./result_tidy_set.txt", row.names = FALSE)
    