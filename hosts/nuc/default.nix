{ config, pkgs, ... }:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  # Realtek R8125 2.5GbE Treiber
  boot.extraModulePackages = [ config.boot.kernelPackages.r8125 ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Netzwerk
  networking.hostName = "nuc";
  networking.hostId = "fdd62ac8"; # Pflicht für ZFS
  networking.useDHCP = true;

  # Zeitzone & Lokalisierung
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de-latin1";

  # Benutzer
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgCqkVI/LR3FFI9z1JLnQylOsteuCg3fP2UXAf/Bnzu philipp.weiss@web.de"
  ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Grundlegende Pakete
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
  ];

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 0;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 0;
  };

  # Firewall
  networking.firewall.enable = true;

  # Flakes aktivieren
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Nix Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "25.05";
}
