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

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs"



curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

VALIDATE $? "Downloading Catalogue Artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "Unzipping Catalogue"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependicies"

#give full path of catalogue.service because we are inside /app
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

VALIDATE $? "Copiying catalogue.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable catalogue &>>$LOGFILE

VALIDATE $? "Enble Catalogue"

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "Start Catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying Mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing MongoClient"

mongo --host mongodb.learndevcloud.online </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "Loading catalogue data "