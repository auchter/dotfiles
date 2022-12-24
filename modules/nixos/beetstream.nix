{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.beetstream;
  yamlFormat = pkgs.formats.yaml { };
  bsPort = 5344;
in {
  options.modules.beetstream = {
    enable = mkEnableOption "beetstream";

    vhost = mkOption {
      type = types.str;
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = { };
    };

    configFile = mkOption {
      type = types.path;
      default = yamlFormat.generate "beetstream.yaml" cfg.settings;
      description = "Config to use instead of generating based on settings";
    };

    package = mkOption {
      default = pkgs.beets.override {
        pluginOverrides = {
          beetstream = {
            enable = true;
            propagatedBuildInputs = [ pkgs.beetstream ];
          };
        };
      };
      description = "beets with beetstream plugin enabled";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."beetstream".source = 
      yamlFormat.generate "beets-config" cfg.settings;

    systemd.services.beetstream = {
      description = "beetstream daemon";
      requires = [ "network.target" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Environment = [
          "BEETSDIR=/run/beetstream"
        ];
        LoadCredential="beetconfig:${cfg.configFile}";
        ExecStart = ''
          ${cfg.package}/bin/beet -c ''${CREDENTIALS_DIRECTORY}/beetconfig beetstream 127.0.0.1 ${toString bsPort}
        '';
        Type = "simple";
        RuntimeDirectory = "beetstream";
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
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" "AF_UNIX" ];
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        TemporaryFileSystem = "/:ro";
        BindReadOnlyPaths = [
          "/nix/store"
          "-/etc/resolv.conf"
          "-/etc/nsswitch.conf"
          "-/etc/hosts"
          "-/etc/localtime"
        ];
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.vhost}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString bsPort}";
            extraConfig =
              "proxy_redirect off;" +
              "proxy_set_header Host $host;" +
              "proxy_set_header X-Real-IP $remote_addr;" +
              "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
              "proxy_set_header X-Forwarded-Proto $scheme;";
          };
        };
      };
    };
  };
}
