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

dnf module disable redis -y &>> $LOGS_FILE
VALIDATE $? "Disabling redis default version"

dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enabling redis:7 version"

dnf install redis -y  &>> $LOGS_FILE
VALIDATE $? "Installing redis"



sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>> $LOGS_FILE
VALIDATE $? "Opening to Remote connections"

sed -i "s/protected-mode yes/protected-mode no/g" /etc/redis/redis.conf &>> $LOGS_FILE
VALIDATE $? "Protected mode turnong off"


systemctl enable redis &>> $LOGS_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOGS_FILE
VALIDATE $? "Starting redis"
