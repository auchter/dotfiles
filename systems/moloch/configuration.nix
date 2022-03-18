{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../../nixos/modules/base.nix
      ../../nixos/modules/users.nix
      ../../nixos/modules/soulseek.nix
      ../../nixos/modules/syncthing.nix
      ../../nixos/modules/dev.nix
      ../../nixos/modules/mpd-client.nix
      ../../nixos/modules/laptop.nix
      ../../nixos/modules/unfree.nix
      ../../nixos/modules/geoclue.nix
      ../../nixos/modules/sops.nix
      ../../nixos/modules/wg-client.nix
      ../../nixos/modules/wifi.nix
#      <nix-ld/modules/nix-ld.nix>
    ];

  networking.hostName = "moloch";
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  networking.wireguard.interfaces.wg0.ips = [ "10.100.0.2/24" ];

  networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets.migadu_password = {
    owner = config.users.users.a.name;
  };
  sops.secrets.gmail_password = {
    owner = config.users.users.a.name;
  };
  sops.secrets.hass_token = {
    owner = config.users.users.a.name;
  };

  fileSystems = lib.listToAttrs (
    map (name:
      lib.nameValuePair "/n/orobas/${name}" {
        device = "orobas.local.phire.org:/export/${name}";
        fsType = "nfs";
        options = [
          "nfsvers=4.2"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600"
          "noauto"
        ];
      })
    [ "music" "videos" "personal" ]
  );

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
      allowDiscards = true;
    };
  };

  environment.systemPackages = with pkgs; [
    home-assistant-cli
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;

  home-manager.users.a = {
    accounts.email.accounts = {
      "a@phire.org" = {
        address = "a@phire.org";
        primary = true;
        realName = "Michael Auchter";
        userName = "a@phire.org";
        passwordCommand = "cat ${config.sops.secrets.migadu_password.path}";
        folders.inbox = "INBOX";
        imap.host = "imap.migadu.com";
        smtp.host = "smtp.migadu.com";
        offlineimap.enable = true;
        notmuch.enable = true;
        neomutt.enable = true;
        msmtp.enable = true;
      };
      "michael.auchter@gmail.com" = {
        address = "michael.auchter@gmail.com";
        primary = false;
        realName = "Michael Auchter";
        userName = "michael.auchter@gmail.com";
        passwordCommand = "cat ${config.sops.secrets.gmail_password.path}";
        folders.inbox = "INBOX";
        flavor = "gmail.com";
        lieer = {
          enable = true;
        };
        notmuch.enable = true;
        neomutt.enable = true;
        msmtp.enable = true;
      };
    };

    programs.notmuch.enable = true;
    programs.neomutt.enable = true;
    programs.msmtp.enable = true;
    programs.offlineimap.enable = true;
    programs.lieer.enable = true;

    home.file.".mailcap".text = ''
      text/html; elinks -dump -dump-width 1000 '%s'; needsterminal; description=HTML Text; nametemplate=%s.html; copiousoutput
      image/jpeg; feh %s;
      image/png; feh %s;
      application/pdf; mupdf %s;
    '';

    home.sessionVariables = {
      HASS_SERVER = "https://home.phire.org";
      HASS_TOKEN = "$(cat ${config.sops.secrets.hass_token.path})";
      MPD_HOST = "phire-preamp";
    };
  };

  services.offlineimap = {
    enable = true;
    install = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
