{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mympd;
in {
  options.services.mympd = {
    enable = mkEnableOption "enable mympd";

    package = mkOption {
      description = "mympd package to use";
      default = pkgs.mympd;
      defaultText = literalExpression "pkgs.mympd";
      type = types.package;
    };

    openFirewall = mkOption {
      description = "open firewall";
      default = false;
      type = types.bool;
    };

    logLevel = mkOption {
      description = "log level";
      default = 5;
      type = types.int;
    };

    mpdHost = mkOption {
      description = "MPD host or path to mpd socket";
      default = null;
      type = types.nullOr types.str;
    };

    mpdPort = mkOption {
      description = "MPD port";
      default = 6600;
      type = types.port;
    };

    httpHost = mkOption {
      description = "IP address to listen on, use [::] to listen on IPv6";
      default = "0.0.0.0";
      type = types.str;
    };

    httpPort = mkOption {
      description = "Port to listen on. Redirects to ssl_port if ssl is set to true";
      default = 80;
      type = types.port;
    };

    ssl = mkOption {
      description = "Use SSL or not";
      default = false;
      type = types.bool;
    };

    sslPort = mkOption {
      description = "Port to listen to https traffic";
      default = 443;
      type = types.port;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      cfg.httpPort
      cfg.sslPort
    ];
      
    systemd.services.mympd = {
      description = "myMPD server daemon";
      after = [ "mpd.service" ];
      requires = [ "network.target" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Environment = [
          "MYMPD_HTTP_HOST=${cfg.httpHost}"
          "MYMPD_HTTP_PORT=${toString cfg.httpPort}"
          "MYMPD_SSL=${boolToString cfg.ssl}"
          "MYMPD_SSL_PORT=${toString cfg.sslPort}"
          "MYMPD_LOGLEVEL=${toString cfg.logLevel}"
        ] ++ lib.optionals (cfg.mpdHost != null) [
          "MPD_HOST=${cfg.mpdHost}"
          "MPD_PORT=${toString cfg.mpdPort}"
        ];
        ExecStart = ''
          ${cfg.package}/bin/mympd -w /run/mympd -a /var/cache/mympd
        '';
        Type = "simple";
        DynamicUser = true;
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictRealtime = true;
        RuntimeDirectory = "mympd";
        CacheDirectory = "mympd";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" "AF_UNIX" ];
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
