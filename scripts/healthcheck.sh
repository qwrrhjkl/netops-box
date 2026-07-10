#!/bin/bash

echo "===== NetOps Box Healthcheck ====="
echo

echo "===== Docker Containers ====="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo "===== Systemd Services ====="
systemctl is-active rsyslog netops-ping netops-trace netops-iperf netops-public-ip netops-flow-receiver 2>/dev/null || true

echo
echo "===== Core API Checks ====="
curl -s http://127.0.0.1:3000/api/health >/dev/null \
  && echo "Grafana OK" || echo "Grafana FAIL"

curl -s http://127.0.0.1:8086/ping >/dev/null \
  && echo "InfluxDB OK" || echo "InfluxDB FAIL"

curl -s http://127.0.0.1:3100/ready | grep -q ready \
  && echo "Loki OK" || echo "Loki FAIL"

curl -s http://127.0.0.1:8088 >/dev/null \
  && echo "Zabbix Web OK" || echo "Zabbix Web FAIL"

echo
echo "===== Oryx / SRS Checks ====="
curl -s http://127.0.0.1/ >/dev/null \
  && echo "Oryx HTTP OK" || echo "Oryx HTTP FAIL"

curl -sk https://127.0.0.1/ >/dev/null \
  && echo "Oryx HTTPS OK" || echo "Oryx HTTPS FAIL"

echo
echo "===== InfluxDB Measurements ====="
docker exec netops-influxdb influx -database netops -execute "SHOW MEASUREMENTS" 2>/dev/null || true

echo
echo "===== Syslog Files ====="
ls -lh /opt/netops-box/logs/syslog 2>/dev/null || true

echo
echo "===== Oryx Container ====="
docker ps | grep netops-oryx || true
