#!/usr/bin/env bash
# https://docs.aws.amazon.com/linux/al2023/ug/ec2.html#launch-via-aws-cli

set -eu

KeyName=aws-key-us-west-2-test
KeyFileName="${KeyName}.tmp"
KeyResult=$(aws ec2 describe-key-pairs --key-names "${KeyName}" | jq '.KeyPairs[0].KeyName' --raw-output)

if [[ "${KeyResult}" != "${KeyName}" ]]; then
    aws ec2 create-key-pair --key-name "${KeyName}" |  jq '.KeyMaterial' --raw-output > "${KeyFileName}"
    chmod 400 "${KeyFileName}"
fi

VpcsLength=$(aws ec2 describe-vpcs | jq '.Vpcs | length' --raw-output)

if [[ "${VpcsLength}" -eq 0 ]]; then
    $SANDBOX_HOME/awscli/ec2/create-default-vpc.sh
fi

SubnetId=$(aws ec2 describe-subnets | jq '.Subnets[0].SubnetId' --raw-output)
SgId=$(aws ec2 describe-security-groups | jq '.SecurityGroups[0].GroupId' --raw-output)

echo $($SANDBOX_HOME/awscli/ec2/authorise-security-group-ingress-all-traffic.sh ${SgId})

aws ec2 run-instances \
  --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-arm64 \
  --instance-type t4g.small \
  --region us-west-2 \
  --key-name ${KeyName} \
  --security-group-ids ${SgId} \
  --subnet-id ${SubnetId} \
  --user-data "file://$SANDBOX_HOME/awscli/ec2/userdata.sh" > instance-created.tmp

InstanceId=$(cat instance-created.tmp | jq '.Instances[0].InstanceId' --raw-output)
State=$(cat instance-created.tmp | jq '.Instances[0].State.name' --raw-output)
PrivateIpAddress=$(cat instance-created.tmp | jq '.Instances[0].PrivateIpAddress' --raw-output)
PublicIpAddress=$(aws ec2 describe-instances --filters Name=instance-id,Values=$InstanceId | jq '.Reservations[0].Instances[0].PublicIpAddress' --raw-output)

echo "InstanceId is ${InstanceId}"
echo "PublicIpAddress is ${PublicIpAddress}"

set +eu