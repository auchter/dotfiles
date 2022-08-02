{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.gocodes;
in {
  options.modules.gocodes = {
    enable = mkEnableOption "Enable gocodes";
    vhost = mkOption {
      type = types.str;
      description = "vhost for gocodes";
    };
    siteMap = mkOption {
      type = types.attrsOf (types.str);
      description = "mapping between shortcodes and url";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.vhost}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/".root = pkgs.writeTextDir "index.html" (''
                <html>
                  <head><title>go shortcodes</title></head>
                  <body><ul>
              '' +
              builtins.foldl' (x: y: x + y) "" (
                builtins.attrValues (
                  lib.mapAttrs (short: url: "    <li>${short} = <a href=\"${url}\">${url}</a></li>\n") cfg.siteMap )) +
              ''
                  </ul></body>
                </html>
              '');
          } // lib.mapAttrs' (short: url: lib.nameValuePair ("/" + short) { return = "301 ${url}"; }) cfg.siteMap;
        };
      };
    };
  };
}
