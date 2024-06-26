{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.graphical;
in {
  options.modules.graphical = {
    enable = mkEnableOption "enable graphical stuff";
    useMpdVolume = mkOption {
      type = types.bool;
      default = false;
      description = "Make keyboard shortcuts control mpd volume";
    };
    laptopOutput = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "name of laptop display output";
    };
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = lib.mkForce true;
    home.packages = with pkgs; [
      # Fonts
      font-awesome
      roboto-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-emoji-blob-bin

      # packages
      feh
      mupdf
      obsidian
      signal-desktop
      screenshot
      pavucontrol
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        font.normal.family = "Noto Sans Mono";
      };
    };

    programs.firefox = {
      enable = true;
    };

    programs.mpv = {
      enable = true;
      config = {
        hwdec = "vaapi";
      };
      profiles = {
        downmix_audio_5_1 = {
          profile-cond = ''get("audio-params/channel-count") >= 5 and get("audio-params/channel-count") < 7'';
          profile-restore = "copy-equal";
          volume-max = "200";
          af = ''lavfi="lowpass=c=LFE:f=120,volume=1.6,pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE"'';
        };
        downmix_audio_7_1 = {
          profile-cond = ''get("audio-params/channel-count") >= 7'';
          profile-restore = "copy-equal";
          volume-max = "200";
          af = ''lavfi="lowpass=c=LFE:f=120,volume=1.6,pan=stereo|FL=0.5*FC+0.3*FLC+0.3*FL+0.3*BL+0.3*SL+0.5*LFE|FR=0.5*FC+0.3*FRC+0.3*FR+0.3*BR+0.3*SR+0.5*LFE"'';
        };
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        terminal = "alacritty";
        modifier = "Mod4";
        workspaceAutoBackAndForth = true;
        keybindings = let
          adjustBrightness = amount: "exec ${pkgs.brightnessctl}/bin/brightnessctl -e -m s ${amount} | cut -d',' -f4 | sed 's/%//' > $SWAYSOCK.wob";
          adjustVolume = amount: "exec ${pkgs.alsa-utils}/bin/amixer -M set Master playback ${amount} | sed -e 's/%//g' -e 's/\\[//g' -e 's/]//g' | awk '/Front (Left|Right):/ { vol += $5 } END { print vol / 2 }' > $SWAYSOCK.wob";
          adjustMpdVolume = amount: "exec ${pkgs.mpc_cli}/bin/mpc volume ${amount} | awk '/volume/ { print $2 }' | tr -d '%' > $SWAYSOCK.wob";
          adjustSnapcastVolume = direction: "exec ${pkgs.home-assistant-cli}/bin/hass-cli service call media_player.volume_${direction} --arguments entity_id=media_player.snapcast_client_phire_preamp | awk '/volume_level: / { print $2 * 100 }' > $SWAYSOCK.wob";
        in lib.mkOptionDefault {
          "XF86AudioMute" = "exec ${pkgs.alsa-utils}/bin/amixer set Master toggle";
          "XF86MonBrightnessUp" = adjustBrightness "1%+";
          "XF86MonBrightnessDown" = adjustBrightness "1%-";
          "Shift+XF86MonBrightnessUp" = adjustBrightness "20%+";
          "Shift+XF86MonBrightnessDown" = adjustBrightness "20%-";
          "XF86AudioRaiseVolume" = if cfg.useMpdVolume then adjustMpdVolume "+1" else adjustVolume "5%+";
          "XF86AudioLowerVolume" = if cfg.useMpdVolume then adjustMpdVolume "-1" else adjustVolume "5%-";
          "Shift+XF86AudioRaiseVolume" = adjustMpdVolume "+1";
          "Shift+XF86AudioLowerVolume" = adjustMpdVolume "-1";
          "XF86AudioMicMute" = "exec amixer set Capture toggle";
          "XF86HomePage" = "exec ${pkgs.sway}/bin/swaymsg output HDMI-A-3 power toggle";
        };
        input = {
          "type:keyboard" = {
            xkb_options = "ctrl:nocaps";
          };
          "1133:49189:B16_b_02_USB-PS/2_Optical_Mouse" = {
            dwt = "disabled";
            pointer_accel = "1";
          };
        };
        bars = [
          {
            command = "${pkgs.waybar}/bin/waybar";
          }
        ];
        startup = [
          { command = "mkfifo $SWAYSOCK.wob"; always = true; }
          { command = "tail -f $SWAYSOCK.wob | ${pkgs.wob}/bin/wob"; always = true; }
          { command = "${pkgs.firefox}/bin/firefox"; }
          { command = "${pkgs.signal-desktop}/bin/signal-desktop"; }
          { command = "${pkgs.obsidian}/bin/obsidian"; }
          { command = "${pkgs.alacritty}/bin/alacritty --class neomutt -e ${pkgs.neomutt}/bin/neomutt"; }
        ];
        # swaymsg -t get_tree
        # see: window_properties
        assigns = {
          "1: web" = [
            { class = "^firefox$"; }
          ];
          "2: msg" = [
            { class = "^Signal$"; }
            { app_id = "^neomutt$"; }
          ];
          "3: notes" = [
            { class = "^obsidian$"; }
          ];
        };
        defaultWorkspace = "workspace number 4";
      };
      extraConfig = mkIf (cfg.laptopOutput != null) ''
        bindswitch --reload --locked lid:on output ${cfg.laptopOutput} disable
        bindswitch --reload --locked lid:off output ${cfg.laptopOutput} enable
      '';
      swaynag = {
        enable = true;
      };
      systemdIntegration = true;
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "after-resume";
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        }
      ];
      timeouts = [
        {
          timeout = 1200;
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        }
      ];
    };

    services.mako = {
      enable = true;
      extraConfig = ''
        [mode=do-not-disturb]
        invisible=1
      '';
    };

    programs.waybar = {
      enable = true;
      settings = {
        bar-0 = {
          layer = "top";
          position = "top";
          height = 30;

          modules-left = [
            "sway/workspaces"
            "sway/mode"
          ];
          modules-center = [
            "sway/window"
          ];
          modules-right = [
            "network"
            "pulseaudio"
            "cpu"
            "memory"
            "disk"
            "backlight"
            "battery"
            "clock"
          ];

          mpd = {
              format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
              format-disconnected = "Disconnected ";
              format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
              unknown-tag = "N/A";
              interval = 2;
              consume-icons = {
                  on = " ";
              };
              random-icons = {
                  off = "<span color=\"#f53c3c\"></span> ";
                  on = " ";
              };
              repeat-icons = {
                  on = " ";
              };
              single-icons = {
                  on = "1 ";
              };
              state-icons = {
                  paused = "";
                  playing = "";
              };
              tooltip-format = "MPD (connected)";
              tooltip-format-disconnected = "MPD (disconnected)";
          };
          idle_inhibitor = {
              format = "{icon}";
              format-icons = {
                  activated = "";
                  deactivated = "";
              };
          };
          tray = {
              spacing = 10;
          };
          clock = {
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              format-alt = "{:%Y-%m-%d}";
              format = "{:%Y-%m-%d %H:%M}";
              timezone = "America/Chicago";
          };
          cpu = {
              format = "{usage}% ";
              tooltip = false;
          };
          memory = {
              format = "{}% ";
          };
          disk = {
            format = "{percentage_used}% /";
          };
          temperature = {
              critical-threshold = 80;
              format = "{temperatureC}°C {icon}";
              format-icons = ["" "" ""];
          };
          backlight = {
              format = "{percent}% {icon}";
              format-icons = ["" ""];
              on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl -m s 1%+";
              on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl -m s 1%-";
          };
          battery = {
              states = {
                  warning = 30;
                  critical = 15;
              };
              format = "{capacity}% {power}W {icon}";
              format-charging = "{capacity}% ";
              format-plugged = "{capacity}% ";
              format-alt = "{time} {power}W {icon}";
              format-icons = ["" "" "" "" ""];
          };
          network = {
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{ipaddr}/{cidr} ";
              tooltip-format = "{ifname} via {gwaddr} ";
              format-linked = "{ifname} (No IP) ";
              format-disconnected = "Disconnected ⚠";
              format-alt = "{ifname} = {ipaddr}/{cidr}";
          };
          pulseaudio = {
              format = "{volume}% {icon} {format_source}";
              format-bluetooth = "{volume}% {icon} {format_source}";
              format-bluetooth-muted = " {icon} {format_source}";
              format-muted = " {format_source}";
              format-source = "{volume}% ";
              format-source-muted = "";
              format-icons = {
                  headphone = "";
                  hands-free = "";
                  headset = "";
                  phone = "";
                  portable = "";
                  car = "";
                  default = ["" "" ""];
              };
              on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
        };
      };
    };
  };
}
