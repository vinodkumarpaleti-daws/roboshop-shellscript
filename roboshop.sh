#!/bin/bash

SG_ID="sg-00329eaa2a9c24c6f"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0175559OQFMTIECQ6IW"
DOMAIN_NAME="jcglobalit.online"

for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \    # Here it creates the Instances passing by CLI
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )

    if [ $instance == "frontend" ]; then  # Here it will give the Public IP if instance is fronted. Else it will print private IP.
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="$DOMAIN_NAME" # jcglobalit.online
    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME" # mongodb.jcglobalit.online
    fi

    echo "IP Address: $IP"

    aws route53 change-resource-record-sets \   # Here it will create the route 53 records.
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '

    echo "record updated for $instance"

done