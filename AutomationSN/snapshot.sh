#!/bin/sh
#exec &> ID.log

echo "Define the pubic IP of the instance:   "
read IP
echo "Define the name of the snapshot:   "
read NAME

ID=$( aws ec2 describe-instances --filters "Name=network-interface.association.public-ip ,Values="$IP --query 'Reservations[*].Instances[*].[InstanceId]' --output text)

VID=$(aws ec2 describe-volumes --region us-east-1 --filters Name=attachment.instance-id,Values=$ID --query 'Volumes[*].[VolumeId]' --output text)

SNID=$(aws ec2 create-snapshot --volume-id $VID --description "This is my root volume snapshot."  --query 'SnapshotId' --output text)

aws ec2 create-tags --resources $SNID --tags Key=Name,Value=$NAME

echo "In process"
exit
