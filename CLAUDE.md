# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commit style

Use [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): description`
Common types: `feat`, `fix`, `chore`, `docs`. Example: `feat(nuc): add German keyboard layout`

## What this repo is

NixOS flake configuration for a single host (`nuc`) — an Intel NUC running NixOS 25.05. The flake also builds a custom installer ISO that bundles the r8125 2.5GbE driver and embeds this config at `/etc/nixos-config`.

## Key commands

```bash
# Apply configuration on the NUC
sudo nixos-rebuild switch --flake .#nuc

# Test without making it permanent
sudo nixos-rebuild test --flake .#nuc

# Update flake inputs (nixpkgs, disko)
nix flake update

# Build the installer ISO
nix build .#isoImage

# Deploy from this machine to a fresh NUC over SSH
nix run github:nix-community/nixos-anywhere -- --flake .#nuc nixos@<nuc-ip>
```

## Architecture

```
flake.nix               # Inputs (nixpkgs 25.05, disko), ISO output, nixosConfigurations.nuc
hosts/nuc/
  default.nix           # Main system config: boot, networking, SSH, packages, ZFS, users
  disk-config.nix       # disko declarative partitioning: GPT + 512M ESP + ZFS pool (rpool)
  hardware-configuration.nix  # Auto-generated; do not edit by hand
```

**Storage layout** (`disk-config.nix`): NVMe (`/dev/nvme0n1`) → GPT → 512M vfat `/boot` + ZFS pool `rpool` (zstd compression). ZFS datasets: `root` `/`, `nix` `/nix`, `home` `/home`, `var` `/var`.

**Notable constraints:**
- `networking.hostId` (`fdd62ac8`) is required by ZFS and must stay in sync with the pool.
- SSH password auth is disabled; only the ed25519 key in `default.nix` can log in as root.
- The r8125 driver is loaded both in the ISO and in the installed system (`boot.extraModulePackages`).
