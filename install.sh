#!/bin/bash
# Install required packages
apt update

apt install python3-all python3-all-dev libpcap-dev libsodium-dev python3-pip python3-pyroute2 \
  python3-future python3-twisted python3-serial iw virtualenv debhelper dh-python build-essential -y

# Build
make

# Install

# Create key and copy to right location
./wfb_keygen
cp *.key /etc/

#cp wfb_tx /usr/bin/
#cp wfb_rx /usr/bin/
#cp wfb_keygen /usr/bin/

cp wfb_* /usr/bin/
cp -r ./wfb_server /usr/sbin/
cp ./wfb_server/wfb.service /etc/systemd/system/

cat <<EOF >> /etc/bash.bashrc
export PATH=\$PATH:/usr/sbin/wfb_server
EOF

# Start wfb_server service
systemctl daemon-reload
systemctl enable wfb.service
systemctl start wfb.service
systemctl status wfb.service
