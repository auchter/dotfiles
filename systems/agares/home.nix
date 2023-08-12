{ config, pkgs, ... }:

{
  programs.alacritty.settings = {
    font.size = 12.0;
    colors.primary.background = "#000000";
  };

  wayland.windowManager.sway.config = {
    input = { # swaymsg - t get_inputs
      "ELAN067B:00 04F3:31F8 Touchpad" = {
        dwt = "enabled";
        tap = "enabled";
        pointer_accel = "1.0";
      };
    };
    output = { # swaymsg -t get_outputs
      eDP-1 = {
        resolution = "2880x1800";
        position = "0,0";
        scale = "1";
      };
    };
  };

  home.packages = with pkgs; [
    esphome
    exiftool

    elinks

    home-assistant-cli
    age
    htop
    moreutils
    nmap
    wget

    roomeqwizard

    sshfs

    kindle-send
  ];


  xdg.enable = true;
  home.sessionVariables = {
    HASS_SERVER = "https://home.phire.org";
    HASS_TOKEN = "$(${pkgs.pass}/bin/pass tokens/hass)";
  };

  modules.calendar.enable = true;
  modules.development.enable = true;
  modules.email.enable = true;
  modules.git.enable = true;
  modules.gpg.enable = true;
  modules.graphical.enable = true;
  modules.tmux.enable = true;
  modules.vim.enable = true;
  modules.zsh.enable = true;
  modules.mpd-client = {
    enable = true;
    host = "malphas";
  };

  modules.beets = {
    enable = true;
    musicDir = "/home/a/Music";
  };

  modules.whipper.enable = true;

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-import ]);
  };
}
