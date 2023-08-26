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

  modules.graphical = {
    enable = true;
    laptopOutput = "eDP-1";
  };

  modules.deck.enable = true;
  modules.vim.colorscheme = "gruvbox_oled";

  xdg.enable = true;
}
