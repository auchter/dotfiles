{ config, pkgs, ... }:

{
  modules.deck = {
    enable = true;
  };

  modules.graphical = {
    enable = true;
    laptopOutput = "eDP-1";
  };

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

  modules.beets = {
    enable = true;
    musicDir = "/home/a/Music";
  };
}
