#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ASSETS_DIR="${SCRIPT_DIR}/../assets/"

go run "${SCRIPT_DIR}/../cmd/kube-controller-manager" --kubeconfig ./assets/.kubeconfig.sample