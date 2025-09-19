#!/usr/bin/env python3
import csv, sys, re
from pathlib import Path
from statistics import mean, pstdev
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def load_times_csv(path: Path):
    byN = {}
    with path.open(newline="") as f:
        rd = csv.DictReader(f)
        for r in rd:
            N = int(r["N"])
            t = float(r["seconds"])
            byN.setdefault(N, []).append(t)
    return byN

def agg_mean_stdev(byN):
    Ns = sorted(byN)
    means = [mean(byN[n]) for n in Ns]
    stdevs = []
    for n in Ns:
        vals = byN[n]
        stdevs.append(pstdev(vals) if len(vals) > 1 else 0.0)
    return Ns, means, stdevs

def parse_p_from_label(label: str):
    m = re.search(r'(\d+)\s*cpu', label.lower())
    return int(m.group(1)) if m else None

def plot_with_err(x, y, yerr, label, ax, ylabel, title):
    ax.errorbar(x, y, yerr=yerr, marker='o', linestyle='-', label=label)
    ax.set_xlabel("N (кол-во задач)")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.grid(True)
    ax.legend()

def save(fig, path):
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)

args = sys.argv[1:]
if not args:
    base = Path.cwd()
    sets = [(base, "current")]
else:
    sets = []
    for a in args:
        if ':' in a:
            d, lab = a.split(':', 1)
        else:
            d, lab = a, Path(a).name
        sets.append((Path(d), lab))

EXPECTED = {
    "cpu_seq": "cpu_seq_times.csv",
    "cpu_par": "cpu_par_times.csv",
    "io_seq":  "io_seq_times.csv",
    "io_par":  "io_par_times.csv",
}

series = {k: [] for k in EXPECTED}
speedups = {"cpu": [], "io": []}

for d, label in sets:
    data = {}
    for key, fname in EXPECTED.items():
        path = d / fname
        if not path.exists():
            continue
        byN = load_times_csv(path)
        Ns, means, stdevs = agg_mean_stdev(byN)
        data[key] = (Ns, means, stdevs)
        series[key].append((label, Ns, means, stdevs))

    for kind in ("cpu", "io"):
        seq_key = f"{kind}_seq"
        par_key = f"{kind}_par"
        if seq_key in data and par_key in data:
            Ns = sorted(set(data[seq_key][0]).intersection(data[par_key][0]))
            if Ns:
                seq_mean = dict(zip(data[seq_key][0], data[seq_key][1]))
                par_mean = dict(zip(data[par_key][0], data[par_key][1]))
                S = [seq_mean[n]/par_mean[n] for n in Ns if par_mean[n] > 0]
                Ns = [n for n in Ns if par_mean[n] > 0]
                speedups[kind].append((label, Ns, S))

outdir = Path.cwd()

def plot_overlay(key, title, pngname, ylabel="Время, сек"):
    fig, ax = plt.subplots(figsize=(10,6))
    any_data = False
    for label, Ns, means, stdevs in series[key]:
        plot_with_err(Ns, means, stdevs, label, ax, ylabel, title)
        any_data = True
    if any_data:
        save(fig, outdir / pngname)

plot_overlay("cpu_seq", "CPU: последовательный запуск", "cpu_seq_time.png")
plot_overlay("cpu_par", "CPU: параллельный запуск",   "cpu_par_time.png")
plot_overlay("io_seq",  "I/O: последовательный запуск", "io_seq_time.png")
plot_overlay("io_par",  "I/O: параллельный запуск",     "io_par_time.png")

# Ускорения
def plot_speedup(kind, title, pngname):
    if not speedups[kind]:
        return
    fig, ax = plt.subplots(figsize=(10,6))
    for label, Ns, S in speedups[kind]:
        ax.plot(Ns, S, marker='o', linestyle='-', label=label)
    ps = {parse_p_from_label(lbl) for lbl,_,_ in speedups[kind]}
    ps = {p for p in ps if p and p>1}
    for p in sorted(ps):
        ax.axhline(p, linestyle='--', linewidth=1, label=f"идеал: {p} CPU")
    ax.set_xlabel("N (кол-во задач)")
    ax.set_ylabel("Ускорение S(N)=Tseq/ Tpar")
    ax.set_title(title)
    ax.grid(True)
    ax.legend()
    save(fig, outdir / pngname)

plot_speedup("cpu", "CPU: ускорение параллельного запуска", "cpu_speedup.png")
plot_speedup("io",  "I/O: ускорение параллельного запуска", "io_speedup.png")

print("Готово:",
      "cpu_seq_time.png, cpu_par_time.png, io_seq_time.png, io_par_time.png,",
      "cpu_speedup.png, io_speedup.png")
