#!/bin/bash
set -e

BASE_DIR="/opt/netops-box"
cd "$BASE_DIR"

echo "============================="
echo " NetOps Box Bootstrap"
echo "============================="

docker network inspect netops-network >/dev/null 2>&1 || docker network create netops-network

mkdir -p data/mysql data/influxdb data/grafana data/loki data/promtail data/zabbix/alertscripts data/zabbix/enc
mkdir -p logs/syslog logs/ping logs/trace logs/traffic backup
mkdir -p oryx/data

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate
pip install --upgrade pip
pip install pyyaml influxdb

chown -R 999:999 "$BASE_DIR/data/mysql" || true
chown -R 472:472 "$BASE_DIR/data/grafana" "$BASE_DIR/apps/grafana/plugins" || true
chown -R 10001:10001 "$BASE_DIR/data/loki" || true

chmod -R 755 "$BASE_DIR/data/mysql" "$BASE_DIR/data/grafana" "$BASE_DIR/apps/grafana/plugins" "$BASE_DIR/data/loki" || true
chmod -R 755 "$BASE_DIR/data/influxdb" "$BASE_DIR/data/promtail" "$BASE_DIR/data/zabbix" || true

chown -R syslog:adm "$BASE_DIR/logs/syslog" 2>/dev/null || true
chmod -R 755 "$BASE_DIR/logs/syslog"

cp "$BASE_DIR/templates/systemd/netops-ping.service" /etc/systemd/system/netops-ping.service
cp "$BASE_DIR/templates/systemd/netops-trace.service" /etc/systemd/system/netops-trace.service
cp "$BASE_DIR/templates/systemd/netops-iperf.service" /etc/systemd/system/netops-iperf.service
cp "$BASE_DIR/templates/systemd/netops-public-ip.service" /etc/systemd/system/netops-public-ip.service 2>/dev/null || true
cp "$BASE_DIR/templates/systemd/netops-flow-receiver.service" /etc/systemd/system/netops-flow-receiver.service 2>/dev/null || true

systemctl daemon-reload
systemctl enable netops-ping netops-trace netops-iperf 2>/dev/null || true

echo "[BOOTSTRAP] Completed."
