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


dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>> $LOGS_FILE
VALIDATE $? "Enabling  mysql-server"

systemctl start mysqld
VALIDATE $? "Starting mysql-server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Updating root mysql-server password"
