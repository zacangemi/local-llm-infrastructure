# Hardware Specification — V1

> **Build status: Complete.** Assembled fall 2024, in continuous production use since.

Complete parts list for the V1 cluster. All prices are at time of purchase (fall 2024) and pre-tax unless noted.

Companion long-form writeup: **[48 GB of VRAM and a Dream — Part 1: The Build](https://blog.zacharycangemi.com/2026/04/29/48-gb-of-vram-and-a-dream-part-1-the-build/)**

## Hardware

| # | Category | Part | Price |
|---|----------|------|-------|
| 1 | GPU | NVIDIA RTX 3090 Founders Edition — 24 GB GDDR6X | $629.96 |
| 2 | GPU | NVIDIA RTX 3090 Founders Edition — 24 GB GDDR6X | $699.99 |
| 3 | CPU | AMD Ryzen 9 7950X3D — 16C/32T, Zen 4, 3D V-Cache, AM5 | $579.99 |
| 4 | Motherboard | ASUS ProArt X870E-CREATOR WiFi — AMD AM5 ATX | $479.99 |
| 5 | RAM | TeamGroup T-Create Expert 96GB Kit (2x48GB) DDR5-6800 CL36 | $345.99 |
| 6 | Storage | Samsung 990 PRO 2TB NVMe — PCIe Gen 4 | $144.99 |
| 7 | CPU Cooler | Lian Li Galahad II LCD-SL Infinity 360mm AIO | $289.99 |
| 8 | PSU | Corsair AX1600i — 1600W, 80+ Titanium, fully modular | $609.99 |
| 9 | Case | Lian Li O11 Dynamic EVO XL — eATX full tower | $234.99 |
| 10 | Fans | Lian Li UNI Fan SL Infinity 120mm — 3-pack | $89.99 |
| 11 | Fans | Lian Li UNI Fan Reverse SL Infinity 120mm × 4 | $119.96 |
| 12 | GPU Cable | Corsair 12-Pin GPU Power Cable | $29.98 |
| 13 | GPU Cable | Corsair 12-Pin GPU Power Cable | $26.98 |
|   | **Hardware Subtotal** |  | **$4,282.79** |

## Protection Plans

| Component | Plan | Cost |
|-----------|------|------|
| GPU #1 (RTX 3090 FE) | 2 Year | $79.99 |
| GPU #2 (RTX 3090 FE) | 2 Year | $79.99 |
| CPU (Ryzen 9 7950X3D) | 2 Year | $69.99 |
| Motherboard (ProArt X870E) | 2 Year | $74.99 |
| AIO Cooler (Galahad II LCD) | 2 Year | $34.99 |
| **Subtotal** |  | **$339.95** |

## Software

| Item | Cost |
|------|------|
| Windows 11 Pro (one-time license) | $199.99 |
| Microsoft 365 Personal (annual subscription, year 1) | $99.99 |
| **Subtotal** | **$299.98** |

## Totals

|  | Amount |
|---|---|
| Pre-tax | $4,922.72 |
| Tax | $412.58 |
| **Grand Total (with tax)** | **$5,335.30** |

---

## PCIe Configuration

The motherboard has 3 PCIe slots:

- **PCIEX16(G5)_1** (PCIe 5.0 x16, CPU-connected) — RTX 3090 FE #1, runs at x8 with both top slots populated
- **PCIEX16(G5)_2** (PCIe 5.0 x16, CPU-connected) — RTX 3090 FE #2, runs at x8 with both top slots populated
- **PCIE_3** (PCIe 4.0 x16 slot, x4 mode, chipset-connected) — unused

When both top slots are populated, the 16 CPU lanes bifurcate into x8/x8.

**Lane-sharing gotcha:** PCIEX16(G5)_2 shares lanes with the M.2_2 NVMe slot. Populating M.2_2 forces slot 1 to x8 and slot 2 to x4. The primary NVMe is in M.2_1 (CPU-connected, no lane sharing) — verified with `nvidia-smi --query-gpu=pcie.link.width.current --format=csv` showing both GPUs at width 8.

Consumer AM5 CPUs only expose 24 usable PCIe lanes (vs. 128 on Threadripper PRO platforms), which is why bifurcation is required for dual-GPU configurations on this socket.

---

## Power Profile

| State | System Total (DC) |
|-------|-------------------|
| Idle | ~112 W |
| AI Inference | ~613 W |
| Max Load | ~991 W |

Per-component breakdown:

| Component | Idle | AI Inference | Max Load |
|---|---|---|---|
| CPU (Ryzen 9 7950X3D) | 15 W | 75 W | 150 W |
| Motherboard (ProArt X870E) | 30 W | 45 W | 55 W |
| GPU #1 (RTX 3090 FE) | 20 W | 220 W | 350 W |
| GPU #2 (RTX 3090 FE) | 20 W | 220 W | 350 W |
| AIO Cooler (pump + LCD) | 4 W | 5 W | 7 W |
| Fans (10× SL Infinity 120mm) | 18 W | 30 W | 52 W |
| RAM (2× 48GB DDR5-6800) | 5 W | 12 W | 18 W |
| Storage (990 PRO 2TB NVMe) | 0.05 W | 5.5 W | 8.5 W |

GPUs are power-limited to 280 W per card via [`scripts/power-limit.sh`](../scripts/power-limit.sh) for thermal headroom and longevity (~4% performance reduction, ~20% power savings, 10–15 °C cooler die temps).

---

## Networking

- Wi-Fi 7 (motherboard onboard, Marvell chipset) for management traffic
- 2.5GbE and 10GbE wired Ethernet available (Marvell + Realtek)
- **Tailscale** mesh VPN (built on WireGuard) for remote SSH access — no public-facing ports, no port forwarding, private 100.x.x.x mesh network
- OpenWebUI exposed on local network port 3000 for browser-based model interaction

---

## Cooling

- **CPU:** Lian Li Galahad II LCD-SL Infinity 360mm AIO (top-mounted, 3× 120mm fans on radiator)
- **Case fans:** 10× Lian Li SL Infinity / Reverse SL Infinity 120mm in **positive pressure** configuration
  - 1 fan: CPU area (single)
  - 3 fans: bottom intake (daisy-chained)
  - 3 fans: rear intake (daisy-chained)
  - 3 fans: AIO radiator (daisy-chained)
- Sustained dual-GPU load yields a 10–15 °C delta between top card (GPU 0) and bottom card (GPU 1) due to FE cards in adjacent PCIe slots with no inter-card gap. Power-limiting to 280 W mitigates throttling but does not eliminate the thermal asymmetry.

---

## Operating System

V1 runs **Windows 11 Pro** (one-time retail license, $199.99 from Microsoft Store).

Known Windows-on-AI-server tradeoffs:
- WDDM display memory overhead: ~0.5–1.5 GB VRAM per GPU depending on resolution and monitor count
- Forced auto-updates (max 5-week pause) can interrupt long-running training jobs
- L-Connect 3 (Lian Li RGB/AIO control software) consumes meaningful CPU when running

Mitigations in place:
- iGPU (Ryzen 7950X3D RDNA 2) handles display output via motherboard HDMI/DisplayPort, freeing discrete GPU VRAM for AI work
- Update pause cycled every 5 weeks
- L-Connect 3 disabled when running training jobs

V2 will be Ubuntu 22.04 LTS from day one — chosen over 24.04 for the most mature CUDA/cuDNN/PyTorch ecosystem support as of 2026.
