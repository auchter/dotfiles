{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "Noto Sans Mono";
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
      keybindings = let
        adjustBrightness = amount: "exec brightnessctl -e -m s ${amount} | cut -d',' -f4 | sed 's/%//' > $SWAYSOCK.wob";
        adjustVolume = amount: "exec amixer -M set Master playback ${amount} | sed -e 's/%//g' -e 's/\\[//g' -e 's/]//g' | awk '/Front (Left|Right):/ { vol += $5 } END { print vol / 2 }' > $SWAYSOCK.wob";
      in lib.mkOptionDefault {
        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86MonBrightnessUp" = adjustBrightness "1%+";
        "XF86MonBrightnessDown" = adjustBrightness "1%-";
        "XF86AudioRaiseVolume" = adjustVolume "5%+";
        "XF86AudioLowerVolume" = adjustVolume "5%-";
        "XF86AudioMicMute" = "exec amixer set Capture toggle";
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

  fonts.fontconfig.enable = lib.mkForce true;

  home.packages = with pkgs; [
    font-awesome
    roboto-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-extra
    noto-fonts-emoji
    noto-fonts-emoji-blob-bin
    grim
    slurp
    dmenu
    feh
    mpv
    mupdf
    obsidian
    signal-desktop
    wob
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
