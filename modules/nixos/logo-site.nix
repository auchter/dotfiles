{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.logo-site;
  hostname = config.networking.hostName;
in {
  options.modules.logo-site = {
    logo = mkOption {
      default = null;
      description = "path to logo";
    };
  };

  config = mkIf (cfg.logo != null) (let
    pkg = pkgs.stdenv.mkDerivation rec {
      pname = "logo-site";
      version = "unstable";
      src = cfg.logo;


      dontUnpack = true;
      dontBuild = true;

      installPhase = let
        index = pkgs.writeText "index.html" ''
          <!doctype html>
          <html lang="en">
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <title>${hostname}.phire.org</title>
              <style>
                body {
                  font-family: helvetica;
                  text-align: center;
                }
                img {
                  border: 10px solid black;
                }
              </style>
            </head>
            <body>
              <img src="logo.png" alt="${hostname}" />
              <h1>${hostname}</h1>
            </body>
          </html>
        '';
      in ''
        mkdir -p $out
        cp -f ${index} $out/index.html
        cp -f ${cfg.logo} $out/logo.png
      '';
    };
  in {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "${hostname}.phire.org" = {
          enableACME = true;
          forceSSL = true;
          locations."/".root = pkg;
        };
      };
    };
  });
}
