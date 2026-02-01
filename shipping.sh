#!/bin/bash

UUID=$(id -u)
LOGS_FOLDER="/var/log/sudo-roboshop"
LOGS_FILE=$LOGS_FOLDER/$0.log
SCRIPT_DIR=$PWD
MYSQL_HOST="mysql.dpavan.online"



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


dnf install maven -y &>> $LOGS_FILE
VALIDATE $? "Installing maven"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding sys user"
else
    echo "user already exists..SKIPPING"
fi


mkdir -p /app
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading shipping backend code"

cd /app 
VALIDATE $? "Moving to app DIR"

rm -rf /app/*   &>> $LOGS_FILE
VALIDATE $? "Removing default code"

unzip /tmp/shipping.zip  &>> $LOGS_FILE
VALIDATE $? "Unzipping shipping code"


cd /app 
mvn clean package &>> $LOGS_FILE
VALIDATE $? "Installing build tool"

mv target/shipping-1.0.jar shipping.jar  &>> $LOGS_FILE
VALIDATE $? "renaming jar name"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service  &>> $LOGS_FILE
VALIDATE $? "copying shipping service"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "Reloading system services"

systemctl enable shipping  &>> $LOGS_FILE
VALIDATE $? "Enabling shipping system services"

systemctl start shipping
VALIDATE $? "Starting shipping system services"


dnf install mysql -y  &>> $LOGS_FILE
VALIDATE $? "Installing mysql-server"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGS_FILE
VALIDATE $? "Loading schema"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGS_FILE
VALIDATE $? "Loading user schema"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGS_FILE
VALIDATE $? "Loading master data schema"

systemctl restart shipping &>> $LOGS_FILE
VALIDATE $? "Restarting shipping"