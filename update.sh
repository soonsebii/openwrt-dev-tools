#!/bin/bash
#
# scp and sysupgrade on remote host
#
# @soonsebii 2016-09-02
#

function abs-path()
{
  realpath $1
}

BINARY_NAME='openwrt-ramips-mt7628-wrtnode2p-squashfs-sysupgrade.bin'
BINARY_PATH=$(abs-path) ./bin/ramips/$BINARY_NAME

TARGET_USER='root'
TARGET_PASS='1234'
TARGET_ADDR='192.168.0.81'
TARGET_TEMP='tmp'

echo "[0] delete known_hosts."
rm -f $HOME/.ssh/known_hosts

echo "[1] copy"
/usr/bin/expect << EOF
spawn scp $BINARY $TARGET_USER@$TARGET_ADDR:/$TARGET_TEMP/.
expect "connecting" { send "yes\r" }
expect "password:"  { send "$TARGET_PASS\r"}
expect eof
EOF

echo "[2] update"
/usr/bin/expect << EOF
spawn ssh $TARGET_USER@$TARGET_ADDR
expect "password:" { send "$TARGET_PASS\r" }
expect -re "(%|#)" { send "sysupgrade -v /tmp/$BINARY_NAME > /dev/ttyS1\r" }
expect eof
EOF

