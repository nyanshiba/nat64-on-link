#!/bin/bash

server=nat64.fro
daemons="nftables radvd ndppd tayga@pp01 tayga@tu10 tayga@tu20"

rsync -rtv \
  --exclude='.git/' \
  --include='*/' \
  --include='radvd.conf' \
  --include='ndppd.conf' \
  --include='tayga/***' \
  --include='sysctl.d/nat64.conf' \
  --include='sysconfig/nftables.conf' \
  --include='systemd/system/***' \
  --include='systemd/network/***' \
  --exclude='*' \
  . "$server:/etc/"

ssh -t $server "systemctl restart $daemons; sleep 1; echo $daemons: \$(systemctl is-active $daemons)"
