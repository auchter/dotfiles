{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.calendar;
in {
  options.modules.calendar = {
    enable = mkEnableOption "enable calendar";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      khal
      khard
    ];

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
  };
}
