{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ../modules/git.nix
    ../modules/gpg-agent.nix
    ../modules/graphical.nix
    ../modules/ncmpcpp.nix
    ../modules/password-store.nix
    ../modules/roomeqwizard.nix
    ../modules/tmux.nix
    ../modules/vim.nix
    ../modules/viddy.nix
    ../modules/zsh.nix
    ../modules/thinkpad_x1c6.nix
  ];


  programs.alacritty.settings = {
    font.size = 12.0;
  };

  programs.himitsu = {
    enable = true;
    browsers = [ "firefox" ];
  };

  home.packages = with pkgs; [
    esphome
    exiftool
    kicad
    zotero

    mpc_cli
    ncmpc
    ncmpcpp

    elinks
    khal
    khard

    home-assistant-cli
    age
    bc
    bmap-tools
    dterm
    htop
    jq
    moreutils
    nmap
    tmux
    wget
  ];

  programs.notmuch.enable = true;
  programs.neomutt.enable = true;
  programs.msmtp.enable = true;
  programs.offlineimap.enable = true;
  programs.lieer.enable = true;
  programs.alot.enable = true;

  home.sessionVariables = {
    HASS_SERVER = "https://home.phire.org";
    HASS_TOKEN = "$(${pkgs.pass}/bin/pass tokens/hass)";
    MPD_HOST = "phire-preamp";
  };

  accounts.email.accounts = {
    "a@phire.org" = {
      address = "a@phire.org";
      primary = true;
      realName = "Michael Auchter";
      userName = "a@phire.org";
      passwordCommand = "${pkgs.pass}/bin/pass email/a@phire.org";
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
      passwordCommand = "${pkgs.pass}/bin/pass tokens/gmail";
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

  home.file.".mailcap".text = ''
    text/html; elinks -dump -dump-width 1000 '%s'; needsterminal; description=HTML Text; nametemplate=%s.html; copiousoutput
    image/jpeg; feh %s;
    image/png; feh %s;
    application/pdf; mupdf %s;
  '';

  modules.vdirsyncer = let
    radicaleConfig = type: {
      type = type;
      url = "https://radicale.phire.org";
      username = "a";
      "password.fetch" = ["command" "${pkgs.pass}/bin/pass" "radicale"];
    };
  in {
    enable = true;
    storage = {
      contacts_local = {
        type = "filesystem";
        path = "~/.contacts";
        fileext = ".vcf";
      };
      calendar_local = {
        type = "filesystem";
        path = "~/.calendars";
        fileext = ".ics";
      };
      contacts_remote = radicaleConfig "carddav";
      calendar_remote = radicaleConfig "caldav";
    };
    pairs = {
      contacts = {
        a = "contacts_local";
        b = "contacts_remote";
        collections = ["from a" "from b"];
      };
      calendar = {
        a = "calendar_local";
        b = "calendar_remote";
        collections = ["from a" "from b"];
      };
    };
  };

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
}
