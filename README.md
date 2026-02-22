# Ollama CUDA (SM_89) — Nix Flake

⚠️ **This build targets NVIDIA Ada GPUs (SM_89 / RTX 40-series) only.**

A Nix flake that builds Ollama from source with CUDA acceleration optimized for RTX 40-series GPUs on x86_64 Linux.

---

## ✨ Features

- CUDA acceleration (llama.cpp backend)
- Optimized for SM_89 (RTX 40-series)
- Pure Nix build (no FHS / no Docker)
- No installation required (use `nix run`)
- Works on NixOS and other Nix-enabled Linux systems

---

## 🖥️ Requirements

- x86_64 Linux
- NVIDIA GPU with CUDA support
- NVIDIA driver installed
- Nix with flakes enabled

Check driver:

```
nvidia-smi

```

---

## 🚀 Quick Start (No Installation)

Run directly from the repository:

```
nix run github:vmemjp/ollama-cuda-flake

```

Start server:

```
nix run github:vmemjp/ollama-cuda-flake -- serve

```

---

## 📦 Install to Profile (Optional)

```
nix profile install github:vmemjp/ollama-cuda-flake

```
Remove:

```
nix profile remove github:vmemjp/ollama-cuda-flake

```

---

## 🧠 Run a Model

```
ollama run qwen3:latest

```

---

## 🔥 Verify GPU Acceleration

In another terminal:

```
watch -n1 nvidia-smi

```

You should see:

- GPU memory usage increasing
- `ollama` process listed

---

## ⚙️ GPU Compatibility

This build is optimized for NVIDIA Ada GPUs (SM_89), including:

- RTX 4070 / 4070 Ti
- RTX 4080
- RTX 4090
- Ada workstation GPUs

It may fail to build or run on older GPUs.

### Using a Different GPU

1. Find your compute capability:

```

nvidia-smi --query-gpu=compute_cap --format=csv,noheader

```

2. Edit `flake.nix`:

Change:

```
-DCMAKE_CUDA_ARCHITECTURES='89'

```

to your value (examples below), then rebuild.

| GPU Family | SM |
|-----------|----|
RTX 40xx (Ada) | 89
RTX 30xx (Ampere) | 86
RTX 20xx / GTX 16xx (Turing) | 75
GTX 10xx (Pascal) | 61

You may also specify multiple architectures:

```
86;89

```

---

## 🧩 Troubleshooting

### GPU not used (CPU fallback)

- Ensure NVIDIA driver is loaded (`nvidia-smi`)
- Check logs:

```
OLLAMA_DEBUG=1 ollama serve

```

### Build fails on non-SM_89 GPUs

Edit the architecture as described above.

---

## 🔄 Updating

This flake tracks upstream Ollama releases manually.  
Update steps:

1. Change version/revision in `flake.nix`
2. Update source hash
3. Recompute `vendorHash`
4. Build

---

## ⚠️ Notes

- This is not an official package
- Built specifically for CUDA on Linux
- Not tested on ROCm / Vulkan / macOS

---

## 📜 License

Ollama is MIT licensed.  
See upstream repository:

https://github.com/ollama/ollama
```

