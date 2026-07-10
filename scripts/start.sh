#!/bin/bash
set -e

cd /opt/netops-box

echo "[START] Starting NetOps Box docker services..."

docker compose --env-file config/netops.env \
  -f compose/00-core.yml \
  -f compose/10-database.yml \
  -f compose/20-grafana.yml \
  -f compose/30-loki.yml \
  -f compose/40-zabbix.yml \
  -f compose/50-telegraf.yml \
  up -d

echo "[START] Starting Oryx..."
cd /opt/netops-box/oryx
docker compose up -d

echo "[START] Restarting systemd services..."
systemctl restart rsyslog
systemctl restart netops-ping netops-trace netops-iperf netops-public-ip netops-flow-receiver 2>/dev/null || true

echo "[START] All services started."
