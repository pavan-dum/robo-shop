#!/bin/bash

IMAGE_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0585ee7d9ca48e3bf"
INST_TYPE="t3.micro"

ZONE_ID="Z02160638EY77GSSE3BP"
DOMAIN_NAME="dpavan.online"



for instance in "$@"
do
    INSTANCE_ID=$( aws ec2 run-instances \
            --image-id $IMAGE_ID \
            --instance-type $INST_TYPE \
            --security-group-ids $SG_ID \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
            --query "Instances[0].InstanceId" \
            --output text
    )
    echo "INSTANCE : $instance and INSTANCE ID: $INSTANCE_ID"

    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    if [ "$instance" = "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text
        )
        DNS_NAME=$DOMAIN_NAME
    else
        IP=$(aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query "Reservations[0].Instances[0].PrivateIpAddress" \
                --output text
        )
        DNS_NAME=$instance.$DOMAIN_NAME
    fi

    echo "Updating DNS: $DNS_NAME → $IP"
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '{
            "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$DNS_NAME'",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{ "Value": "'$IP'" }]
            }
            }]
        }'


done