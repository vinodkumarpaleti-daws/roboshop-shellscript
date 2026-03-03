#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/logs/roboshop-shellscript"
LOGS_FILE="$LOGS_FOLDER/$0.log"

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

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Install MySQL server"

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld
VALIDATE $? "Enable and start mysql"

# get the password from user
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setup root password"