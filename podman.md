# Running Ollama with Podman (CUDA)

An alternative to building from source with this flake.
Uses the official Ollama container image with GPU passthrough via NVIDIA Container Toolkit.

## Setup (NixOS)

Add to your NixOS configuration:

```nix
virtualisation.podman.enable = true;
virtualisation.containers.cdi.dynamic.nvidia.enable = true;
```

Then rebuild:

```
sudo nixos-rebuild switch
```

## Run

```
podman run -d \
  --name ollama \
  --device nvidia.com/gpu=all \
  -p 11434:11434 \
  -v ollama:/root/.ollama \
  ollama/ollama
```

## Verify GPU

```
podman exec ollama nvidia-smi
```

## Update

```
podman pull ollama/ollama
podman rm -f ollama
```

Then re-run the `podman run` command above.

## References

- [ollama/ollama - Docker Hub](https://hub.docker.com/r/ollama/ollama)
- [Ollama CUDA with Podman Quadlets](https://brandonrozek.com/blog/ollama-cuda-podman-quadlets/)
