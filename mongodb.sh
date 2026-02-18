#!/bin/bash
R="\e[31m"  # It will print in Red Color
G="\e[32m"  # It will print in Green Color
Y="\e[33m"  # It will print in Yellow Color
B="\e[34m"  # It will print in Blue Color
P="\e[35m"  # It will print in Pink Color
N="\e[0m"   # It will print in Normal Color

USERID=$(id -u)
LOGS_FOLDER="/var/logs/shell-sript/"
LOGS_FILE="$LOGS_FOLDER/$0.logs"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"



