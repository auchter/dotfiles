{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 12.0;
      font.normal.family = "Roboto Mono";
    };
  };

  programs.firefox = {
    enable = true;
  };

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      terminal = "alacritty";
      modifier = "Mod4";
      workspaceAutoBackAndForth = true;
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
      keybindings = let
        adjustBrightness = amount: "exec brightnessctl -e -m s ${amount} | cut -d',' -f4 | sed 's/%//' > $SWAYSOCK.wob";
        adjustVolume = amount: "exec amixer -M set Master playback ${amount} | sed -e 's/%//g' -e 's/\\[//g' -e 's/]//g' | awk '/Front (Left|Right):/ { vol += $5 } END { print vol / 2 }' > $SWAYSOCK.wob";
      in lib.mkOptionDefault {
        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86MonBrightnessUp" = adjustBrightness "1%+";
        "XF86MonBrightnessDown" = adjustBrightness "1%-";
        "XF86AudioRaiseVolume" = adjustVolume "5%+";
        "XF86AudioLowerVolume" = adjustVolume "5%-";
      };
      bars = [
        {
          command = "waybar";
        }
      ];
    };
    swaynag = {
      enable = true;
    };
    systemdIntegration = true;
    extraConfig = ''
      exec_always mkfifo $SWAYSOCK.wob
      exec_always tail -f $SWAYSOCK.wob | wob
    '';
  };

  programs.waybar = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    font-awesome
    roboto-mono
    grim
    slurp
    dmenu
    feh
    mpv
    obsidian
    signal-desktop
    wob
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "obsidian"
  ];

  # obsidian currently depends on an old electron version, ugh
  nixpkgs.config.permittedInsecurePackages = [ "electron-13.6.9" ];

  #services.swayidle = {
  #  enable = true;
  #  events = [
  #    {
  #      event = "resume";
  #      command = "swaymsg \"output * dpms on\"";
  #    }
  #    {
  #      event = "before-sleep";
  #      command = "swaylock -f -c 000000";
  #    }
  #  ];
  #  timeouts = [
  #    {
  #      timeout = 1200;
  #      command = "swaylock -f -c 000000";
  #    }
  #    {
  #      timeout = 1400;
  #      command = "swaymsg \"output * dpms off\"";
  #    }
  #  ];
  #};

  programs.mako = {
    enable = true;
  };

}
