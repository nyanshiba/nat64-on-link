#!/bin/bash

server=nat64.fro
if [ "$1" == "" ]; then
  daemons="radvd tayga@* nat64-routes"
else
  daemons=$@
fi

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

rsync -av --chown=mitmproxy:mitmproxy mitmproxy/ "$server:/home/mitmproxy/"

ssh -t $server "systemctl daemon-reload; systemctl restart $daemons; sleep 1; echo $daemons: \$(systemctl is-active $daemons)"
