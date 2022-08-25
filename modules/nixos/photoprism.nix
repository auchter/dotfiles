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
      description = "Folder from which files can be transferred to the originals folder in a structured way that avoids duplicates"
    };
  };

  config = mkIf (cfg.enable) {
    networking.firewall.allowedTCPPorts = [ 2342 ];
    virtualisation.oci-containers = {
      containers = {
        photoprism = {
          image = "photoprism/photoprism@sha256:042afacef24270f7d055611b0526ba5b7f4f7d6f2f974d247adabd28c56dabc8";
          volumes = [
            "${storageDir}:/photoprism/storage"
            "${originalsDir}:/photoprism/originals"
            "${importDir}:/photoprism/import"
          ];
          ports = [ "2342:2342" ];
          environment = {
            PHOTOPRISM_ADMIN_PASSWORD = "woopwoop";
          };
        };
      };
    };
  };
}
