{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.listenbrainz-mpd;
in {
  options.services.listenbrainz-mpd = {
    enable = mkEnableOption "enable listenbrainz-mpd";
    package = mkOption {
      description = "listenbrainz-mpd package to use";
      default = pkgs.listenbrainz-mpd;
      defaultText = literalExpression "pkgs.listenbrainz-mpd";
      type = types.package;
    };

    mpdHost = mkOption {
      description = "mpd host to connect to";
      default = "localhost:6600";
      type = types.str;
    };

    tokenFile = mkOption {
      description = "file containing listenbrainz user token";
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.listenbrainz-mpd = {
      description = "listenbrainz-mpd client";
      after = [ "network.target" "mpd.service" ];
      wantedBy = [ "mpd.service" ];
      serviceConfig = {
        LoadCredential = "token:${cfg.tokenFile}";
        Environment = [
          "XDG_CONFIG_DIR=/run/listenbrainz-mpd"
        ];
        ExecStartPre = pkgs.writeShellScript lb-mpd ''
          mkdir -p /run/listenbrainz-mpd/listenbrainz-mpd
          TOKEN=$(cat ''${CREDENTIALS_DIRECTORY}/token)
          cat <<EOF >/run/listenbrainz-mpd/listenbrainz-mpd/config.toml
          [submission]
          token = "$TOKEN"

          [mpd]
          address = "${cfg.mpdHost}"
          EOF
        '';
        ExecStart = "${cfg.package}/bin/listenbrainz-mpd";
        Type = "simple";
        Restart = "always";
        DynamicUser = true;
        RuntimeDirectory = "listenbrainz-mpd";
      };
    };
  };
}
