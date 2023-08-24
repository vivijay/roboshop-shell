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

yum install nginx -y &>>$LOGFILE

VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE

VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE

VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE

VALIDATE $? "Removing default index html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE

VALIDATE $? "Downloading web artifact"

cd /usr/share/nginx/html &>>$LOGFILE

VALIDATE $? "Moving to default HTML directory"

unzip /tmp/web.zip &>>$LOGFILE

VALIDATE $? "unzipping web artifact"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>>$LOGFILE

VALIDATE $? "copying roboshop config"

systemctl restart nginx  &>>$LOGFILE

VALIDATE $? "Restarting Nginx"