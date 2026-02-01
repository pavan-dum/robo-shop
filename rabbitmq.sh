#!/bin/bash

UUID=$(id -u)
LOGS_FOLDER="/var/log/sudo-roboshop"
LOGS_FILE=$LOGS_FOLDER/$0.log
SCRIPT_DIR=$PWD

USER="roboshop"
PASS="roboshop123"
VHOST="/"


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


cp $SCRIPT_DIR/rabbit.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGS_FILE
VALIDATE $? "Copying rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server
VALIDATE $? "Starting rabbitmq server"

# Create user if not exists
if ! rabbitmqctl list_users | grep -w "^$USER" &>/dev/null; then
    rabbitmqctl add_user "$USER" "$PASS" &>> $LOGS_FILE
    VALIDATE $? "Adding user"
else
    echo "User already exists: SKIPPING"
fi


# Set permissions (safe to re-run)
rabbitmqctl set_permissions -p "$VHOST" "$USER" ".*" ".*" ".*"  &>> $LOGS_FILE
VALIDATE $? "Setting password"