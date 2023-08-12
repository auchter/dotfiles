{ config, pkgs, ... }:

{
  programs.alacritty.settings = {
    font.size = 12.0;
  };

  wayland.windowManager.sway.config = {
    input = { # swaymsg - t get_inputs
      "1739:0:Synaptics_TM3289-021" = {
        dwt = "enabled";
        tap = "enabled";
        pointer_accel = "0.8";
      };
    };
    output = { # swaymsg -t get_outputs
      eDP-1 = {
        resolution = "2560x1440";
        position = "0,0";
        scale = "1";
      };
    };
  };

  modules.graphical = {
    enable = true;
    laptopOutput = "eDP-1";
  };

  home.packages = with pkgs; [
    esphome
    exiftool

    home-assistant-cli

    kindle-send
  ];


  home.sessionVariables = {
    HASS_SERVER = "https://home.phire.org";
    HASS_TOKEN = "$(${pkgs.pass}/bin/pass tokens/hass)";
  };

  modules.calendar.enable = true;
  modules.development.enable = true;
  modules.email.enable = true;
  modules.git.enable = true;
  modules.gpg.enable = true;
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

  programs.password-store.enable = true;
}
