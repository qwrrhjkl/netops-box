#!/usr/bin/env python3
import subprocess
import time
import sys
from pathlib import Path

BASE = Path("/opt/netops-box")
sys.path.insert(0, str(BASE))

from lib.config import load_yaml
from lib.logger import get_logger
from lib.metrics import MetricsWriter

log = get_logger("netops.ping")
writer = MetricsWriter(host="127.0.0.1")

cfg = load_yaml(str(BASE / "config" / "targets.yml"))
interval = int(cfg.get("ping", {}).get("interval", 5))
targets = cfg.get("ping", {}).get("targets", [])

def ping_once(ip: str):
    result = subprocess.run(["ping", "-c", "1", "-W", "1", ip], capture_output=True, text=True)
    latency = None
    loss = 1

    if result.returncode == 0:
        loss = 0
        for part in result.stdout.split():
            if part.startswith("time="):
                latency = float(part.split("=")[1])
                break

    return latency, loss

log.info("ping engine started")

while True:
    for target in targets:
        name = target.get("name", target.get("ip"))
        ip = target.get("ip")
        if not ip:
            continue

        latency, loss = ping_once(ip)
        fields = {"loss": loss}
        if latency is not None:
            fields["latency_ms"] = latency

        writer.write("network_ping", {"target": name, "ip": ip}, fields)
        log.info(f"target={name} ip={ip} latency={latency} loss={loss}")

    time.sleep(interval)
