#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/logs/roboshop-shellscript"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.jcglobalit.online

# Color Codes

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

# Check root user access

if [ $USERID -ne 0 ]; then
    echo -e "$R Run this script with root user access. $N" | tee -a $LOGS_FILE
    exit
fi

# Create the Logs folder if it does not exist

mkdir -p $LOGS_FOLDER


# VALIDATE $? "Second Argument"

# In the above validate statement '$?' checks the previous command status and store it in the first argument ($1).
# We can pass any echo statement or anything on the second argument ($2).

# Validate function for command usage and pass the arguments directly in the VALIDATE() function.

VALIDATE(){
  if [ $1 -ne 0 ]; then
    echo "$2.....$R FAILURE $N" | tee -a $LOGS_FILE
  else
    echo "$2.....$G SUCCESS $N" | tee -a $LOGS_FILE
  fi
}
# disabling nodejs module
dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling NodeJS Default version"

# enabling nodejs 20 version
dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling NodeJS 20"

# installing nodejs
dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install NodeJS"

# creating roboshop user
id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading user code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "Uzip user code"

npm install  &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable user  &>>$LOGS_FILE
systemctl start user
VALIDATE $? "Starting and enabling user"

