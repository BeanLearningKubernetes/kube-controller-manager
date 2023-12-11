#!/usr/bin/env bash

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-api-cli
# To see what went wrong https://stackoverflow.com/questions/27086639/user-data-scripts-is-not-running-on-my-custom-ami-but-working-in-standard-amazo

yum update -y
# service httpd start
# chkconfig httpd on

curl https://dl.google.com/go/go1.21.5.linux-arm64.tar.gz --output go1.21.5.linux-arm64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.5.linux-arm64.tar.gz

BASH_RC_DIR=/home/ec2-user/.bashrc.d

mkdir -p ${BASH_RC_DIR}

echo 'export PATH=$PATH:/usr/local/go/bin' > ${BASH_RC_DIR}/go.sh

ETCD_VER=v3.5.10

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-arm64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-arm64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-arm64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-arm64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-arm64.tar.gz
mv /tmp/etcd-download-test /usr/local/etcd

export LOCAL_IP=$(ip route get 1 | awk '{print $7;exit}')
export ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
export ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
export ETCD_INITIAL_CLUSTER="default=http://${LOCAL_IP}:2380,default=http://localhost:2380"
export ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${LOCAL_IP}:2380,http://localhost:2380"
export ETCD_ADVERTISE_CLIENT_URLS="http://${LOCAL_IP}:2379,http://localhost:2379"

cat > ${BASH_RC_DIR}/etcd.sh << EOF
export PATH=$PATH:/usr/local/etcd

export LOCAL_IP=${LOCAL_IP}

export ETCD_LISTEN_PEER_URLS=${ETCD_LISTEN_PEER_URLS}
export ETCD_LISTEN_CLIENT_URLS=${ETCD_LISTEN_CLIENT_URLS}
export ETCD_INITIAL_CLUSTER=${ETCD_INITIAL_CLUSTER}
export ETCD_INITIAL_ADVERTISE_PEER_URLS=${ETCD_INITIAL_ADVERTISE_PEER_URLS}
export ETCD_ADVERTISE_CLIENT_URLS=${ETCD_ADVERTISE_CLIENT_URLS}
EOF

cat > /home/ec2-user/env << EOF
ETCD_LISTEN_PEER_URLS=${ETCD_LISTEN_PEER_URLS}
ETCD_LISTEN_CLIENT_URLS=${ETCD_LISTEN_CLIENT_URLS}
ETCD_INITIAL_CLUSTER=${ETCD_INITIAL_CLUSTER}
ETCD_INITIAL_ADVERTISE_PEER_URLS=${ETCD_INITIAL_ADVERTISE_PEER_URLS}
ETCD_ADVERTISE_CLIENT_URLS=${ETCD_ADVERTISE_CLIENT_URLS}
EOF

cat > /etc/systemd/system/etcd.service << EOF
[Unit]
Description=etcd service

[Service]
EnvironmentFile=/home/ec2-user/env
ExecStart=/usr/local/etcd/etcd
Restart=always

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd

# TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
# curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4
