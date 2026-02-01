#!/bin/bash

UUID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE=$LOGS_FOLDER/$0.log

if [ $UUID -ne 0 ]; then
    echo "Please get ROOT ACCESS to execute."
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo "$2.....FAILURE"
    else
        echo "$2.....SUCCESS"
    fi
}


dnf module disable nodejs -y
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling Nodejs:20 version"

dnf install nodejs -y
VALIDATE $? "Installing Nodejs:20"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding system user"

mkdir /app 
VALIDATE $? "Creating app directory/folder"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading backend nodejs code"

cd /app
VALIDATE $? "changinf directory to app folder"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzippinf code"

cd /app 
npm install
VALIDATE $? "Installing npm Build tool"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Creating backend catalogue service"

systemctl daemon-reload
VALIDATE $? "Reloading system services"

systemctl enable catalogue
VALIDATE $? "Enabling catalogue system services"

systemctl start catalogue
VALIDATE $? "Starting catalogue system services"\

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo repo"

dnf install mongodb-mongosh -y
VALIDATE $? "Installing mongodb clinet"

mongosh --host mongodb.dpavan.online </app/db/master-data.js
VALIDATE $? "Loading products information"