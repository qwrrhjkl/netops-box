#!/bin/bash
set -e

systemctl daemon-reload

for svc in rsyslog netops-ping netops-trace netops-iperf; do
  echo "Restarting $svc"
  systemctl restart "$svc" || true
  systemctl status "$svc" --no-pager -l || true
done
