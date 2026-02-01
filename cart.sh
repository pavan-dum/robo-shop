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
    if [ $1 -ne 0 ]; then
        echo "$2....FAILURE" | tee -a $LOGS_FILE
        exit 1
    else
        echo "$2....SUCCESS" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling default nodejs version"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing nodejs version"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating sys user"
else
  echo "user already exists..SKIPING"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading cart code"

cd /app 
VALIDATE $? "Moving to app dir"

rm -rf /app/* &>> $LOGS_FILE
VALIDATE $? "Removing feault code"

unzip /tmp/cart.zip &>> $LOGS_FILE
VALIDATE $? "Unzipping cart code"

cd /app 
npm install  &>> $LOGS_FILE
VALIDATE $? "installing build tool"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>> $LOGS_FILE
VALIDATE $? "Copying cart service"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "Reloading systemctl servics"

systemctl enable cart  &>> $LOGS_FILE
VALIDATE $? "Enabling cart servics"

systemctl start cart
VALIDATE $? "Starting cart servics"

