#!/bin/bash

component=$1

if [ -z "${component}" ]; then
  echo "Enter the component to start"
  exit 1
fi

LTid=lt-0dde63c285c407ba5
ver=5

## To launch the template without name
##aws ec2 run-instances --launch-template LaunchTemplateId=lt-0dde63c285c407ba5,Version=5

##Validate Instrance is already there
INSTANCE_CREATED() {
INSTANCE_STATE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${component}" | jq .Reservation[].Instance[].State.Name | xargs -n1)
if [ "${INSTANCE_STATE}" = "running" ]; then
  echo"instance is already there"
  DNS_UPDATE
  exit 0
fi

if [ "{INSTANCE_STATE}" = "stopped" ]; then
  echo"instance is already there"
    exit 0
fi

##To launch the instance with name
aws ec2 run-instances --launch-template LaunchTemplateId=${LTid},Version=${ver} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${component}}]" | jq
sleep 20
DNS_UPDATE
}

DNS_UPDATE() {
IPADDR=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${component}" | jq .Reservation[].Instance[].PrivateIpAddress | xargs -n1)
sed -e "s/COMPONENT/${component}" -e "s/IPADDRESS/${IPADDR}" record.json  >>/tmp/record.json
aws route53 get-hosted-zone --id Z048532427Z8A2VSNE7P3 --change-batch file:///tmp.record.json | jq
}