{
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

        modules = {
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
              on-scroll-up = "brightnessctl -m s 1%+";
              on-scroll-down = "brightnessctl -m s 1%-";
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
              on-click = "pavucontrol";
          };
        };
      };
    };
  };
}
