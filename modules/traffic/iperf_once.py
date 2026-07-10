#!/usr/bin/env python3
import subprocess
import json
import sys
from pathlib import Path

BASE = Path("/opt/netops-box")
sys.path.insert(0, str(BASE))

from lib.config import load_yaml
from lib.logger import get_logger
from lib.metrics import MetricsWriter

log = get_logger("netops.iperf_once")
writer = MetricsWriter(host="127.0.0.1")

cfg = load_yaml(str(BASE / "config" / "traffic.yml"))
tests = cfg.get("iperf3", {}).get("tests", [])

for test in tests:
    name = test.get("name")
    server = test.get("server")
    port = str(test.get("port", 5201))
    duration = str(test.get("duration", cfg.get("iperf3", {}).get("default_duration", 10)))

    if not server:
        continue

    result = subprocess.run(
        ["iperf3", "-c", server, "-p", port, "-t", duration, "-J"],
        capture_output=True,
        text=True,
    )

    success = 1 if result.returncode == 0 else 0
    bps = 0

    if success:
        data = json.loads(result.stdout)
        bps = data.get("end", {}).get("sum_received", {}).get("bits_per_second", 0)

    writer.write(
        "network_iperf",
        {"test": name, "server": server, "port": port},
        {"bps": float(bps), "success": success},
    )
    log.info(f"test={name} server={server} bps={bps} success={success}")
