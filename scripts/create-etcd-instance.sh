#!/usr/bin/env bash

set -eu

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SANDBOX_HOME=${SCRIPT_DIR}

$SANDBOX_HOME/awscli/ec2/create-instance.sh