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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip &>>$LOGFILE

VALIDATE $? "Downloading cart Artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/cart.zip &>>$LOGFILE

VALIDATE $? "Unzipping cart"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependicies"

#give full path of cart.service because we are inside /app
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE

VALIDATE $? "Copiying cart.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable cart &>>$LOGFILE

VALIDATE $? "Enble cart"

systemctl start cart &>>$LOGFILE

VALIDATE $? "Start cart"