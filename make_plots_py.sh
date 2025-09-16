#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab5
IN="${1:-watch_mem.csv}"

python3 - <<'PYCODE'
import csv, pathlib, datetime as dt
from collections import defaultdict

base = pathlib.Path("/home/user/lab5")
infile = base / ("watch_mem.csv")
import sys
if len(sys.argv) > 1:
    infile = pathlib.Path(sys.argv[1])

ts_fmt = "%Y-%m-%d %H:%M:%S"

sys_rows = []
rss_mem, rss_mem2 = [], []
cpu_mem, cpu_mem2 = [], []

with infile.open(newline="") as f:
    rd = csv.DictReader(f)
    for r in rd:
        ts = dt.datetime.strptime(r["ts"], ts_fmt)
        try:
            sys_rows.append((ts, int(r["MemFree_kB"]), int(r["MemAvail_kB"]), int(r["SwapFree_kB"])))
        except Exception:
            pass
        cmd = r.get("COMMAND","")
        try:
            rss = int(r["RSS_KB"]); cpu = float(r["CPU_PCT"])
        except Exception:
            continue
        if "mem2.bash" in cmd:
            rss_mem2.append((ts, rss)); cpu_mem2.append((ts, cpu))
        elif "mem.bash" in cmd:
            rss_mem.append((ts, rss)); cpu_mem.append((ts, cpu))

sys_rows.sort(); rss_mem.sort(); rss_mem2.sort(); cpu_mem.sort(); cpu_mem2.sort()

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def save_lines(xy_list, labels, title, ylabel, outfile):
    plt.figure(figsize=(11,6.5))
    for (xs, ys), label in zip(xy_list, labels):
        plt.plot(xs, ys, label=label)
    plt.grid(True)
    plt.legend(loc="best")
    plt.xlabel("Время")
    plt.ylabel(ylabel)
    plt.title(title)
    plt.tight_layout()
    plt.savefig(outfile)
    plt.close()
if sys_rows:
    xs = [t for t,_,_,_ in sys_rows]
    y1 = [m for _,m,_,_ in sys_rows]
    y2 = [m for *_,m,_ in sys_rows]
    y3 = [s for *_,s in sys_rows]
    save_lines([(xs,y1),(xs,y2),(xs,y3)],
               ["MemFree_kB","MemAvailable_kB","SwapFree_kB"],
               "Динамика системной памяти", "kB", base/"sys_mem.png")

if rss_mem and rss_mem2:
    xs1, y1 = zip(*rss_mem)
    xs2, y2 = zip(*rss_mem2)
    save_lines([(xs1,y1),(xs2,y2)],
               ["mem.bash","mem2.bash"],
               "RSS (резидентная память) процессов", "RSS, kB", base/"rss_mem.png")
elif rss_mem:
    xs1, y1 = zip(*rss_mem)
    save_lines([(xs1,y1)], ["mem.bash"], "RSS (резидентная память) процесса", "RSS, kB", base/"rss_mem.png")


if cpu_mem and cpu_mem2:
    xs1, y1 = zip(*cpu_mem)
    xs2, y2 = zip(*cpu_mem2)
    save_lines([(xs1,y1),(xs2,y2)],
               ["mem.bash","mem2.bash"],
               "%CPU процессов", "%CPU", base/"cpu_mem.png")
elif cpu_mem:
    xs1, y1 = zip(*cpu_mem)
    save_lines([(xs1,y1)], ["mem.bash"], "%CPU процесса", "%CPU", base/"cpu_mem.png")

def load_report(p):
    if not p.exists(): return None
    vals=[]
    with p.open() as f:
        for line in f:
            line=line.strip()
            if not line: continue
            try: vals.append(int(line))
            except: pass
    if not vals: return None
    xs=list(range(len(vals)))
    return xs, vals

arr1 = load_report(base/"report.log")
arr2 = load_report(base/"report2.log")

if arr1 and arr2:
    save_lines([arr1, arr2], ["mem.bash","mem2.bash"],
               "Рост размера массива (каждые 100000 шагов)", "элементы", base/"array_size.png")
elif arr1:
    save_lines([arr1], ["mem.bash"],
               "Рост размера массива (каждые 100000 шагов)", "элементы", base/"array_size.png")

print("Готово: sys_mem.png, rss_mem.png, cpu_mem.png, array_size.png")
PYCODE
