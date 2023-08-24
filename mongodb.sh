#!/bin/bash
USERID=$(id -u)
R="\e[31m"
N="\e[0m"
G="\e[32m"
DATE=$(date)
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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB repo into yum.repos.d"

yum install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installation of Mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling Mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Edited mongod.conf"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarted mongod"


