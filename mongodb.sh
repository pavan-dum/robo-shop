#!/bin/bash

UUID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE=$LOGS_FOLDER/$0.log

if [ $UUID -ne 0 ]; then
    echo "Please get ROOT ACCESS to execute."
    exit 1
fi


VALIDATE (
    if [ $1 -ne 0 ]; then
        echo "$2.....FAILURE." | tee -a $LOGS_FILE
    else
        echo "$2.....SUCCESS." | tee -a $LOGS_FILE
    else
    fi
)

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "Enabling mongod service"

systemctl start mongod &>> $LOGS_FILE
VALIDATE $? "Starting mongod service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGS_FILE
VALIDATE $? "Opening remote connnections"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "Restarting mongod service"