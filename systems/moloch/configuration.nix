{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
      ../../nixos/modules/soulseek.nix
      ../../nixos/modules/syncthing.nix
      ../../nixos/modules/laptop.nix
      ../../nixos/modules/wg-client.nix
      ../../nixos/modules/wifi.nix
      ../../nixos/modules/restic.nix
    ];

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
  sops.secrets.radicale_password = {
    owner = config.users.users.a.name;
  };
  sops.secrets.restic_password = {};
  sops.secrets.restic_env = {};

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

  services.restic.backups.backblaze = {
    paths = [
      "/home/a/photos"
      "/home/a/Maildir"
      "/home/a/obsidian"
      "/home/a/proj"
    ];
  };

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
    programs.alot.enable = true;

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

    home.packages = with pkgs; [
      elinks
      khal
      khard
      vdirsyncer
    ];

    xdg.configFile."vdirsyncer/config".text = ''
      [general]
      status_path = "~/.vdirsyncer/status/"

      [pair contacts]
      a = "contacts_local"
      b = "contacts_remote"
      collections = ["from a", "from b"]

      [storage contacts_local]
      type = "filesystem"
      path = "~/.contacts"
      fileext = ".vcf"

      [storage contacts_remote]
      type = "carddav"
      url = "https://radicale.phire.org"
      username = "a"
      password.fetch = ["command", "cat", "${config.sops.secrets.radicale_password.path}"]

      [pair calendar]
      a = "calendar_local"
      b = "calendar_remote"
      collections = ["from a", "from b"]

      [storage calendar_local]
      type = "filesystem"
      path = "~/.calendars"
      fileext = ".ics"

      [storage calendar_remote]
      type = "caldav"
      url = "https://radicale.phire.org"
      username = "a"
      password.fetch = ["command", "cat", "${config.sops.secrets.radicale_password.path}"]
    '';

    xdg.configFile."khard/khard.conf".text = ''
      [addressbooks]
      [[contacts]]
      path = ~/.contacts/348ac56f-198f-c8a4-a671-9d13de60eb4b

      [general]
      default_action = list
      merge_editor = vimdiff

      [contact table]
      show_nicknames = yes
      show_uids = no
      localize_dates = no
    '';

    xdg.configFile."khal/config".text = ''
      [calendars]

      [[calendar_local]]
      path = ~/.calendars/*
      type = discover

      [locale]
      timeformat = %H:%M
      dateformat = %Y-%m-%d
      longdateformat = %Y-%m-%d
      datetimeformat = %Y-%m-%d %H:%M
      longdatetimeformat = %Y-%m-%d %H:%M
      local_timezone = America/Chicago
      default_timezone = America/Chicago

      [default]
      default_calendar = 9bacadaa-74d7-e673-249c-0b3859a3e2c3
    '';

  };

  systemd.user.services.vdirsyncer = {
    description = "vdirsyncer sync";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    };
  };

  systemd.user.timers.vdirsyncer = {
    description = "vdirsyncer sync";
    timerConfig = {
      OnCalendar = "*:0/5";
      Unit = "vdirsyncer.service";
    };
    wantedBy = [ "default.target" ];
  };

  # systemd doesn't support recursive directory watches.
  # could watch each specific directory instead, though...
  #systemd.user.paths.vdirsyncer = {
  #  pathConfig = {
  #    Unit = "vdirsyncer.service";
  #    PathChanged = [ "${config.users.users.a.home}/.calendars" "${config.users.users.a.home}/.contacts" ];
  #  };
  #  wantedBy = [ "default.target" ];
  #};

  services.offlineimap = {
    enable = true;
    install = true;
  };

  # HACK: globally enable sway instead of relying on home-manager to ensure /etc/pam.d/swaylock gets installed
  programs.sway.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
