#!/bin/bash
USERID=$(id -u)
R="\e[31m"
N="\e[0m"
G="\e[32m"
DATE=$(date +%F)
SCRIPTNAME=$0
LOGSDIR=/tmp
LOGFILE=$LOGSDIR/$SCRIPTNAME-$DATE.log

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R Failure $N "
    else
        echo -e "$2.... $G Installed $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo -e "$R Error : Please run this script with root access $N"
    exit 1
fi

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing Nodejs"

#once the user is created, if you run this script 2nd time
# this command will defnitely fail
# IMPROVEMENT: first check the user already exist or not, if not exist then create
useradd roboshop &>>$LOGFILE

#write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? "Downloading user Artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/user.zip &>>$LOGFILE

VALIDATE $? "Unzipping user"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependicies"

#give full path of user.service because we are inside /app
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "Copiying user.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable user &>>$LOGFILE

VALIDATE $? "Enble user"

systemctl start user &>>$LOGFILE

VALIDATE $? "Start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying Mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing MongoClient"

mongo --host mongodb.learndevcloud.online </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Loading user data "