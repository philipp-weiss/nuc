# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commit style

Use [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): description`
Common types: `feat`, `fix`, `chore`, `docs`. Example: `feat(nuc): add German keyboard layout`

## What this repo is

NixOS flake configuration for a single host (`nuc`) — an Intel NUC running NixOS 25.11 whose primary workload is Home Assistant (with a Zigbee/ZHA USB dongle). The flake also builds a custom installer ISO that bundles the r8125 2.5GbE driver and embeds this config at `/etc/nixos-config`.

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
flake.nix               # Inputs (nixpkgs 25.11, disko, agenix), ISO output, nixosConfigurations.nuc
hosts/nuc/
  default.nix           # Main system config: boot, networking, SSH, ZFS, Home Assistant, restic client
  disk-config.nix       # disko declarative partitioning: GPT + 512M ESP + ZFS pool (rpool)
  hardware-configuration.nix  # Auto-generated; do not edit by hand
secrets.nix             # agenix recipient list (phip + nuc keys) at repo root
secrets/*.age           # Encrypted secret files
```

**Storage layout** (`disk-config.nix`): NVMe (`/dev/nvme0n1`) → GPT → 512M vfat `/boot` + ZFS pool `rpool` (zstd compression). ZFS datasets: `root` `/`, `nix` `/nix`, `home` `/home`, `var` `/var`.

**ZFS:** auto-scrub enabled, auto-snapshot keeps 7 daily snapshots (frequent/hourly/weekly/monthly disabled).

**Home Assistant** (`services.home-assistant`): listens on `0.0.0.0:8123` (firewall opens 8123); extra components `zha`, `homeassistant_hardware`, `met`; `hass` user is in `dialout` for the Zigbee USB dongle. Inline automations control a Sonoff valve (`switch.sonoff_swv`) for garden watering — Mon/Wed/Sat 04:00 start in months 4–10 unless ≥3 mm rain forecast in the next 24 h, with an unconditional 06:30 stop.

**Restic backup** (client → testy): nightly at 02:00, `/var/lib/hass` minus the SQLite recorder DB; append-only repo at `restic.pweiss.org` (managed by the `nixos_config` repo). Repository URL and password come from agenix secrets `restic-repository.age` and `restic-password.age`. Pruning runs server-side on testy.

**agenix:** recipients are `phip` (user) and `nuc` (host). Edit secrets from repo root:
```bash
nix run github:ryantm/agenix -- -e secrets/restic-repository.age
nix run github:ryantm/agenix -- -e secrets/restic-password.age
```

**Auto-upgrade:** `system.autoUpgrade` pulls `github:philipp-weiss/nuc#nuc` daily at 04:00 with `allowReboot = true` — pushed commits roll out automatically.

**Notable constraints:**
- `networking.hostId` (`fdd62ac8`) is required by ZFS and must stay in sync with the pool.
- SSH password auth is disabled; only the ed25519 key in `default.nix` can log in as root.
- The r8125 driver is loaded both in the ISO and in the installed system (`boot.extraModulePackages`).
