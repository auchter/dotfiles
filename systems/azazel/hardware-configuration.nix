# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c396a021-4bf8-4590-b1ee-b2a01603219c";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/988D-7431";
    fsType = "vfat";
  };

  fileSystems."/mnt/unenc" = {
    device = "/dev/disk/by-label/storage-unenc";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/mnt/storage" = {
    device = "UUID=0789211e-1c89-442a-8372-d66172a9fe0c";
    fsType = "ext4";
    options = [
      "noauto"
      "noatime"
#      "x-mount.mkdir"
      "x-systemd.requires=systemd-cryptsetup@storage_enc.service"
    ];
  };

  environment.etc.crypttab = {
    enable = true;
    text = ''
      storage_enc UUID=6d1c1ba4-62d5-4f46-a93a-e627fd186b35 none luks,noauto
    '';
  };

  environment.systemPackages = with pkgs; [
    cryptsetup
  ];

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
