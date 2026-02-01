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


dnf install python3 gcc python3-devel -y &>> $LOGS_FILE
VALIDATE $? "Installing python devel"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Adding sys user"
else
    VALIDATE $? "User already exist SKIPPING"
fi

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>> $LOGS_FILE
VALIDATE $? "Downloading payment code"

cd /app 
VALIDATE $? "Moving app DIR"

rm -rf /app/*   &>> $LOGS_FILE
VALIDATE $? "Removing default payment code"

unzip /tmp/payment.zip   &>> $LOGS_FILE
VALIDATE $? "Unzipping code"

cd /app 
pip3 install -r requirements.txt  &>> $LOGS_FILE
VALIDATE $? "Installing build tool"


cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service  &>> $LOGS_FILE
VALIDATE $? "Copying payment service"

systemctl daemon-reload  &>> $LOGS_FILE
VALIDATE $? "Reloading system payment service"

systemctl enable payment &>> $LOGS_FILE
VALIDATE $? "Enabling system payment service"

systemctl start payment
VALIDATE $? "Starting system payment service"