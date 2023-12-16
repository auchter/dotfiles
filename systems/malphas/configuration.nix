{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_6_5;
  boot.kernelPatches = [
    {
      name = "ina260";
      patch = ./PATCH-hwmon-Add-support-for-the-INA260-chip-to-the-INA219-and-compatibles-driver.patch;
      extraConfig = ''
        SENSORS_INA2XX y
      '';
    }
  ];

  networking.interfaces.eth0.useDHCP = true;
  modules.sshd.enable = true;

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/053afcd9-26c3-4fde-8466-40280f1195b3";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  modules.syncthing = {
    enable = true;
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  hardware.bluetooth = {
    enable = true;
  };

  services.avahi = {
    enable = false;
    nssmdns = false;
  };

  system.activationScripts.irq-affinity = ''
    echo e > /proc/irq/240/smp_affinity
  '';

  environment.systemPackages = with pkgs; [
    camilladsp
    listenbrainz-mpd
  ];

  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
    4953
  ];

  sops.secrets.listenbrainz_pass = {};

  services.listenbrainz-mpd = {
    enable = true;
    tokenFile = config.sops.secrets.listenbrainz_pass.path;
    mpdHost = "azazel.local.phire.org";
  };

  services.ampctrl = {
    enable = true;
    mpdHost = "azazel.local.phire.org";
  };

  services.ttctrl = {
    enable = false;
    mpdHost = "azazel.local.phire.org";
  };

  boot.kernelModules = [ "snd-aloop" ];
  sound = {
    enable = true;
  };

  hardware.gpio.enable = true;
  hardware.i2c.enable = true;
  hardware.deviceTree.overlays = [
    {
      name = "preamp-line-names";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@0 {
            target = <&pio>;
            __overlay__ {
              gpio-line-names =
                /* A */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* B */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* C */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* D */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "RELAY_PWR", "TRIG_OUT_0", "TRIG_OUT_1", "TRIG_OUT_2", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* E */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* F */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* G */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* H */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "";
            };
          };
        };
      '';
    }
    {
      name = "ina260";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@1 {
            target = <&i2c0>;
            __overlay__ {
              status = "okay";
              ina260@40 {
                compatible = "ti,ina260";
                reg = <0x40>;
              };
            };
          };
        };
      '';
    }
  ];

  system.stateVersion = "22.05"; # Did you read the comment?
}

