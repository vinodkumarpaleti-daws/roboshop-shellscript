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
    echo "$2.....FAILURE" | tee -a $LOGS_FILE
  else
    echo "$2.....SUCCESS"
  fi
}

dnf module disable redis -y &>>$LOGS_FILE

VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y &>>$LOGS_FILE

VALIDATE $? "Enabling redis 7"

dnf install redis -y &>>$LOGS_FILE

VALIDATE $? "Installing Redis"

# update the redis.conf
# Replacing the 127.0.0.1 to 0.0.0.0 in /etc/redis/redis.conf using ' sed -i ' command
# Replacing the protected-mode from yes to no in in /etc/redis/redis.conf 'sed -i'

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing Remote connections"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "Redis enabling success"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Start the redis"
