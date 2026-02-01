#!/bin/bash

UUID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE=$LOGS_FOLDER.$0.log

if [ $UUID -ne 0 ]; then
    echo "Please get ROOT ACCESS to execute"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE () {
    if [ $? -ne 0 ]; then
        echo "$2.....FAILURE" | tee -a $LOGS_FILE
    else
        echo "$2.....SUCCESS" | tee -a $LOGS_FILE
    fi
}


dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disabling Nginx default version"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "Enabling nginx:1.24 version"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Instaling Nginx"

systemctl enable nginx
VALIDATE $? "Enabling nginx service"

systemctl start nginx
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing default nginx html"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading frontend html code"

cd /usr/share/nginx/html
VALIDATE $? "moving to html code directory"

unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping frontend html code"
 
cp nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Copying ngix config file"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Restarting Nginx"