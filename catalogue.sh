#!/bin/bash

UUID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE=$LOGS_FOLDER/$0.log
SCRIPT_DIR=$PWD

if [ $UUID -ne 0 ]; then
    echo "Please get ROOT ACCESS to execute."
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo "$2.....FAILURE" | tee -a $LOGS_FILE
    else
        echo "$2.....SUCCESS" | tee -a $LOGS_FILE
    fi
}


dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Nodejs:20 version"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing Nodejs:20"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Adding system user"
else
    echo " User already exist..SKIPPING"
fi

mkdir -p /app | tee -a $LOGS_FILE
VALIDATE $? "Creating app directory/folder"

rm -rf /app/* | tee -a $LOGS_FILE
VALIDATE $? "Removong code in app dir"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading backend nodejs code"

cd /app | tee -a $LOGS_FILE
VALIDATE $? "changing directory to app folder to download code"

unzip /tmp/catalogue.zip &>> $LOGS_FILE
VALIDATE $? "Unzipping code"

cd /app 
npm install &>> $LOGS_FILE
VALIDATE $? "Installing npm Build tool"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGS_FILE
VALIDATE $? "Creating backend catalogue service"

systemctl daemon-reload | tee -a $LOGS_FILE
VALIDATE $? "Reloading system services"

systemctl enable catalogue | tee -a $LOGS_FILE
VALIDATE $? "Enabling catalogue system services"

systemctl start catalogue | tee -a $LOGS_FILE
VALIDATE $? "Starting catalogue system services"\

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "Copying mongo repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "Installing mongodb clinet"

mongosh --host mongodb.dpavan.online </app/db/master-data.js &>> $LOGS_FILE
VALIDATE $? "Loading products information"