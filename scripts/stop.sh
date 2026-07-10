#!/bin/bash
set -e

echo "[STOP] Stopping NetOps Box..."

cd /opt/netops-box

echo "[STOP] Stopping systemd services..."
systemctl stop netops-ping netops-trace netops-iperf netops-public-ip netops-flow-receiver 2>/dev/null || true

echo "[STOP] Stopping Oryx..."
cd /opt/netops-box/oryx
docker compose down

echo "[STOP] Stopping docker services..."
cd /opt/netops-box
docker compose \
  -f compose/10-database.yml \
  -f compose/20-grafana.yml \
  -f compose/30-loki.yml \
  -f compose/40-zabbix.yml \
  -f compose/50-telegraf.yml \
  down

echo "[STOP] Completed."
