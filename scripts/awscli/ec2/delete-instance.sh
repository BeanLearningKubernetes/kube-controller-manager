#!/usr/bin/env bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/terminate-instances.html

set -eu

InstanceId=$1

aws ec2 terminate-instances --instance-ids $InstanceId