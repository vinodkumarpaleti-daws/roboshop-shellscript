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
    echo -e "$2.....$R FAILURE $N" | tee -a $LOGS_FILE
  else
    echo -e "$2.....$G SUCCESS $N" | tee -a $LOGS_FILE
  fi
}

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "Enabling nginx 1.24"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOGS_FILE
systemctl start nginx
VALIDATE $? "Enabled and started nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Remove default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and unzipped frontend"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Deleting default nginx config"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx
VALIDATE $? "Restarted Nginx"