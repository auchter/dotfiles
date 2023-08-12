{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.email;
in {
  options.modules.email = {
    enable = mkEnableOption "enable email";

    frequency = mkOption {
      type = types.str;
      default = "*:0/5";
    };

    blockIfNoYubikey = mkOption {
      type = types.bool;
      description = "when true, waits service won't run if no yubikey is inserted";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.notmuch.enable = true;
    programs.neomutt.enable = true;
    programs.msmtp.enable = true;
    programs.offlineimap.enable = true;
    programs.lieer.enable = true;
    programs.alot.enable = true;

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
        folders.inbox = "mail";
        flavor = "gmail.com";
        lieer = {
          enable = true;
        };
        notmuch.enable = true;
        neomutt.enable = true;
        msmtp.enable = true;
      };
    };

    systemd.user.services.offlineimap = {
      Unit = {
        Description = "offlineimap";
      };
      Service = {
        Environment = [
          "PASSWORD_STORE_DIR=/home/a/.local/share/password-store"
        ];
        ExecCondition = mkIf cfg.blockIfNoYubikey "${pkgs.usbutils}/bin/lsusb -d 1050:";
        ExecStart = "${pkgs.offlineimap}/bin/offlineimap";
        Type = "oneshot";
      };
    };

    systemd.user.timers.offlineimap = {
      Unit = { Description = "offlineimap sync"; };
      Timer = {
        Unit = "offlineimap.service";
        OnCalendar = cfg.frequency;
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };

    home.file.".mailcap".text = ''
      text/html; ${pkgs.elinks}/bin/elinks -dump -dump-width 1000 '%s'; needsterminal; description=HTML Text; nametemplate=%s.html; copiousoutput
      image/jpeg; ${pkgs.feh}/bin/feh %s;
      image/png; ${pkgs.feh}/bin/feh %s;
      application/pdf; ${pkgs.mupdf}/bin/mupdf %s;
      text/calendar; ${pkgs.khal}/bin/khal import %s;
      application/ics; ${pkgs.khal}/bin/khal import %s;
    '';
  };
}
