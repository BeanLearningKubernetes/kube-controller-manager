#!/usr/bin/env bash

if [ -d './kubernetes' ]; then
  echo $(cd kubernetes && git pull)
else
  git clone git@github.com:kubernetes/kubernetes.git
fi

KUBE_CLONE=./kubernetes

mkdir -p ./cmd
cp -R ${KUBE_CLONE}/cmd/* ./cmd/

STAGING=staging/src/k8s.io
mkdir -p "./${STAGING}"

cp ${KUBE_CLONE}/go.mod ./
cp -R ${KUBE_CLONE}/${STAGING}/* ${STAGING}

PKG=pkg
mkdir -p pkg
cp -R ${KUBE_CLONE}/${PKG}/* ${PKG}

TEST=test
mkdir -p ${TEST}
cp -R ${KUBE_CLONE}/${TEST}/* ${TEST}

PLUGIN=plugin
mkdir -p ${PLUGIN}
cp -R ${KUBE_CLONE}/${PLUGIN}/* ${PLUGIN}

THIRD=third_party
mkdir -p ${THIRD}
cp -R ${KUBE_CLONE}/${THIRD}/* ${THIRD}

go mod tidy