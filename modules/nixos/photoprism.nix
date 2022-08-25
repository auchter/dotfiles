{ config, lib, ... }:

with lib;

let
  cfg = config.modules.photoprism;
in {
  options.modules.photoprism = {
    enable = mkEnableOption "photoprism";
    storageDir = mkOption {
      description = "SQLite, cache, session, thumbnail and sidecar files are created in the storage folder";
    };
    originalsDir = mkOption {
      description = "Directory which contains photos and videos";
    };
    importDir = mkOption {
      description = "Folder from which files can be transferred to the originals folder in a structured way that avoids duplicates";
    };
    vhost = mkOption { };
  };

  config = mkIf (cfg.enable) {

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.vhost}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2342";
          proxyWebsockets = true;
          extraConfig =
            "proxy_redirect off;" +
            "proxy_set_header Host $host;" +
            "proxy_set_header X-Real-IP $remote_addr;" +
            "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
            "proxy_set_header X-Forwarded-Proto $scheme;";
        };
      };
    };

    virtualisation.oci-containers = {
      containers = {
        photoprism = {
          image = "photoprism/photoprism@sha256:042afacef24270f7d055611b0526ba5b7f4f7d6f2f974d247adabd28c56dabc8";
          volumes = [
            "${cfg.storageDir}:/photoprism/storage"
            "${cfg.originalsDir}:/photoprism/originals"
            "${cfg.importDir}:/photoprism/import"
          ];
          ports = [ "2342:2342" ];
          environment = {
            PHOTOPRISM_ADMIN_PASSWORD = "changeme1234";
          };
        };
      };
    };
  };
}
