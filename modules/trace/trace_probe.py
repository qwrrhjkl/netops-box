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

log = get_logger("netops.trace")
writer = MetricsWriter(host="127.0.0.1")

cfg = load_yaml(str(BASE / "config" / "targets.yml"))
interval = int(cfg.get("trace", {}).get("interval", 60))
targets = cfg.get("trace", {}).get("targets", [])

def trace_once(ip: str):
    result = subprocess.run(["traceroute", "-n", "-w", "1", "-q", "1", ip], capture_output=True, text=True)
    hops = 0
    last_hop = ""

    for line in result.stdout.splitlines()[1:]:
        parts = line.split()
        if len(parts) >= 2:
            hops += 1
            last_hop = parts[1]

    return hops, last_hop, result.returncode

log.info("trace probe started")

while True:
    for target in targets:
        name = target.get("name", target.get("ip"))
        ip = target.get("ip")
        if not ip:
            continue

        hops, last_hop, rc = trace_once(ip)
        writer.write(
            "network_trace",
            {"target": name, "ip": ip},
            {"hops": hops, "success": 1 if rc == 0 else 0},
        )
        log.info(f"target={name} ip={ip} hops={hops} last_hop={last_hop} rc={rc}")

    time.sleep(interval)
