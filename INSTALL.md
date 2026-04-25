# NixOS NUC Installation

## Vorbereitung

1. NixOS minimal ISO auf USB-Stick schreiben (nixos.org)
2. NUC vom USB-Stick booten
3. SSH aktivieren (im Live-System):
   ```bash
   sudo systemctl start sshd
   passwd nixos  # temporäres Passwort setzen
   ip addr       # IP-Adresse notieren
   ```

## Installation (vom eigenen PC aus)

Diese Konfiguration auf den NUC übertragen:
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#nuc \
  nixos@<nuc-ip>
```

## Nach der Installation

SSH-Schlüssel in hosts/nuc/default.nix eintragen, dann:
```bash
ssh phip@<nuc-ip>
sudo nixos-rebuild switch --flake github:dein-user/nixos-config#nuc
```

## Wichtige Befehle

```bash
# Konfiguration anwenden
sudo nixos-rebuild switch --flake .#nuc

# Konfiguration testen (ohne dauerhaft zu aktivieren)
sudo nixos-rebuild test --flake .#nuc

# System aktualisieren
nix flake update
sudo nixos-rebuild switch --flake .#nuc
```
