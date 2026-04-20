#!/bin/bash

server=nat64.fro
daemons="radvd ndppd tayga@pp01 tayga@pp03 tayga@tu00 tayga@tu10 tayga@tu20 tayga@warp tayga@warp2"

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

ssh -t $server "systemctl daemon-reload; systemctl restart $daemons; sleep 1; echo $daemons: \$(systemctl is-active $daemons)"
