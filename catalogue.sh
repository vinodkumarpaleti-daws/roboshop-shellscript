#!/bin/bash
R="\e[31m"  # It will print in Red Color
G="\e[32m"  # It will print in Green Color
Y="\e[33m"  # It will print in Yellow Color
B="\e[34m"  # It will print in Blue Color
P="\e[35m"  # It will print in Pink Color
N="\e[0m"   # It will print in Normal Color

USERID=$(id -u)
LOGS_FOLDER="/var/logs/roboshop-shellscript/"
LOGS_FILE="$LOGS_FOLDER/$0.logs"
SCRIPT_DIR=$PWD

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling NodeJs Default version"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing Nodejs"

id roboshop &>> $LOGS_FILE

if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating system user"
else
    echo "roboshop user already exist...$Y skipping $N"
fi

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "Creating App directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>> $LOGS_FILE
VALIDATE $? "Downloading catalogue code"

cd /app
VALIDATE $? "Moving to App directory"
rm -rf /app/*
VALIDATE $? "Removing existing content in the App directory"

unzip /tmp/catalogue.zip &>> $LOGS_FILE
VALIDATE $? "Unziping catalogue code"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing npm dependencies"
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service  &>> $LOGS_FILE
VALIDATE $? "Creating systemctl service"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "Daemon reload"

systemctl enable catalogue &>> $LOGS_FILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGS_FILE
VALIDATE $? "Starting catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOGS_FILE

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')  # This will check if the products are loaded or not.

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>$LOGS_FILE
VALIDATE $? "Restarting catalogue"

