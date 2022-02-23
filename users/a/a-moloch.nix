{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ../../nixos/modules/unfree.nix
    ../modules/git.nix
    ../modules/gpg-agent.nix
    ../modules/graphical.nix
    ../modules/ncmpcpp.nix
    ../modules/password-store.nix
    ../modules/roomeqwizard.nix
    ../modules/tmux.nix
    ../modules/vim.nix
    ../modules/zsh.nix
  ];

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

  programs.alacritty.settings = {
    font.size = 12.0;
  };

  home.packages = with pkgs; [
    esphome
    kicad
  ];
}
