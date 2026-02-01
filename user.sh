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
VALIDATE $? "Istalling nodejs"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Adding sys user"
    
else
    echo "roboshop user already exists SKIPPING"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOGS_FILE
VALIDATE $? "DOwnloading user backend code"

cd /app
VALIDATE $? "moving to app directory"

rm -rf /app/* &>> $LOGS_FILE
VALIDATE $? "Removing default app DIR code"

unzip /tmp/user.zip &>> $LOGS_FILE
VALIDATE $? "Unzipping user code"

cd /app 
npm install &>> $LOGS_FILE
VALIDATE $? "Installing build tool"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>> $LOGS_FILE
VALIDATE $? "copying user service"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "Reloading systemctl services"

systemctl enable user &>> $LOGS_FILE
VALIDATE $? "Enabling user"

systemctl start user
VALIDATE $? "Starting user"
