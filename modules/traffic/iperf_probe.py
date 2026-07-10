#!/usr/bin/env python3
import subprocess
import time
from pathlib import Path

BASE = Path("/opt/netops-box")
INTERVAL = 300

while True:
    subprocess.run(["python3", str(BASE / "modules" / "traffic" / "iperf_once.py")])
    time.sleep(INTERVAL)
