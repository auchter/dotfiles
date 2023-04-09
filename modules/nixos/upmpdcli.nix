{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.upmpdcli;
in {
  options.modules.upmpdcli = {
    enable = mkEnableOption "upmpdcli";

    package = mkOption {
      description = "upmpdcli package to use";
      default = pkgs.upmpdcli;
      defaultText = literalExpression "pkgs.upmpdcli";
      type = types.package;
    };

    mpdHost = mkOption {
      type = types.str;
      default = "localhost";
    };

    mpdPort = mkOption {
      type = types.port;
      default = 6600;
    };

    upnpPort = mkOption {
      type = types.port;
      default = 49152;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      cfg.upnpPort
    ];

    networking.firewall.allowedUDPPorts = lib.optionals cfg.openFirewall [
      cfg.upnpPort
      1900
    ];

    systemd.services.upmpdcli = {
      description = "upmpdcli";
      after = [ "network.target" "mpd.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Environment = [
          "UPMPD_HOST=${cfg.mpdHost}"
          "UPMPD_PORT=${toString cfg.mpdPort}"
          "UPMPD_UPNPPORT=${toString cfg.upnpPort}"
        ];
        ExecStart = "${cfg.package}/bin/upmpdcli";
        Type = "simple";
        DynamicUser = true;
        Restart = "always";
        CacheDirectory = "upmpdcli";
      };
    };
  };
}
