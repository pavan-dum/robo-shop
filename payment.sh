#!/bin/bash

UUID=$(id -u)
LOGS_FOLDER="/var/log/sudo-roboshop"
LOGS_FILE=$LOGS_FOLDER/$0.log
SCRIPT_DIR=$PWD



if [ $UUID -ne 0 ]; then
    echo "Please get ROOT ACCESS for execute"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE () {
    if [ $? -ne 0 ]; then
        echo "$2....FAILURE" | tee -a $LOGS_FILE
        exit 1
    else
        echo "$2....SUCCESS" | tee -a $LOGS_FILE
    fi
}


dnf install python3 gcc python3-devel -y
VALIDATE $? "Installing python devel"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding sys user"
else
    VALIDATE $? "User already exist SKIPPING"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading payment code"

cd /app 
VALIDATE $? "Moving app DIR"

rm -rf /app/*
VALIDATE $? "Removing default payment code"

unzip /tmp/payment.zip
VALIDATE $? "Unzipping code"

cd /app 
pip3 install -r requirements.txt
VALIDATE $? "Installing build tool"


cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying payment service"

systemctl daemon-reload
VALIDATE $? "Reloading system payment service"

systemctl enable payment 
VALIDATE $? "Enabling system payment service"

systemctl start payment
VALIDATE $? "Starting system payment service"