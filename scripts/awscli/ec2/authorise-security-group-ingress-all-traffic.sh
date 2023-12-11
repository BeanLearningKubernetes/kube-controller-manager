#!/usr/bin/env bash

set -eu

aws ec2 authorize-security-group-ingress --group-id "${1}" --ip-permissions IpProtocol=all,IpRanges="[{CidrIp=0.0.0.0/0}]"

