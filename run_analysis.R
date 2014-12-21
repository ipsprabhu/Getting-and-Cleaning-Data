library(plyr)
#Read the Test data, its label and associated subject.
setwd("C:/Work/UCI HAR Dataset/test")
test_data<- read.table("X_test.txt")
test_label<- read.table("y_test.txt")
test_subject<- read.table("subject_test.txt")
test_data<- cbind(cbind(test_data,test_label),test_subject)

#Read the Training data, its label and associated subject.
setwd("C:/Work/UCI HAR Dataset/train")
train_data<- read.table("X_train.txt")
train_label<- read.table("y_train.txt")
train_subject<- read.table("subject_train.txt")
train_data<- cbind(cbind(train_data,train_label),train_subject)

# 1. Merge the training and test datasets to create the master dataset.
data<- rbind(test_data,train_data)

#Read activity and features file.
setwd("C:/Work/UCI HAR Dataset")
Activity<- read.table("activity_labels.txt",col.names=c("Activity_Id",
                                                        "Activity Desc"))
Features<- read.table("features.txt",colClasses=c("character"))

#Assign column names to the merged dataset.
Features<- rbind(rbind(Features,c(562, "Activity_Id")),c(563, "Subject"))[,2]
names(data)<- Features

#2. Extract the mean and standard deviation measurements only.
data_mean_std<- data[,grepl("mean|std|Activity_Id|Subject", names(data))]

#3. Use descriptive activity names to name the activity.
data_mean_std<- join(data_mean_std,Activity,by="Activity_Id",match="first")
data_mean_std<- data_mean_std[,-1]

#4.Appropriately label the dataset with descriptive variable names.
# remove the parantheses.
names(data_mean_std)<- gsub('\\(|\\)',"",names(data_mean_std),perl=TRUE)
#check the syntax of the variable name. 
names(data_mean_std)<- make.names(names(data_mean_std))
#Assign descriptive names.
names(data_mean_std)<- gsub('Acc',"Acceleration",names(data_mean_std))
names(data_mean_std)<- gsub('Mag',"Magnitude",names(data_mean_std))
names(data_mean_std)<- gsub('^t',"TimeDomain",names(data_mean_std))
names(data_mean_std)<- gsub('^f',"FrequencyDomain",names(data_mean_std))
names(data_mean_std)<- gsub('\\.mean',".Mean",names(data_mean_std))
names(data_mean_std)<- gsub('\\.std',".StandardDeviation",names(data_mean_std))
names(data_mean_std)<- gsub('Freq\\.',"Frequency.",names(data_mean_std))

#5. Create a tidt dataset with the average of each variable for each subject and
# activity.
tidy_data = ddply(data_mean_std, c("Subject","Activity.Desc"), numcolwise(mean))
#Write the dataset to a text fie.
write.table(tidy_data, file = "tidy_data.txt")
