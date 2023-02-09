{ config, lib, ... }:

with lib;

let
  cfg = config.modules.syncthing;
  hostname = config.networking.hostName;
  syncfolders = {
    "pixel_5a_g1cs-photos" = {
      pixel5a = {};
      moloch = {
        path = "~/Camera";
        type = "receiveonly";
      };
    };
    "music" = {
      stolas = {
        path = "/mnt/storage/music";
        type = "sendonly";
      };
      malphas = {
        path = "/mnt/storage/music";
        type = "receiveonly";
      };
    };
    "music.opus" = {
      pixel5a = {};
      stolas = {
        path = "/mnt/storage/music.opus";
        type = "sendonly";
      };
      moloch = {
        path = "~/music.opus";
        type = "receiveonly";
      };
    };
    "obsidian" = {
      pixel5a = {};
      moloch = {
        path = "~/obsidian";
        type = "sendreceive";
      };
    };
  };
in {
  options.modules.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    users.users.syncthing.homeMode = "770";

    services.syncthing = {
      enable = true;
      devices = import ./syncthing-devices.nix {};
      folders = mapAttrs (id: share: {
        id = id;
        devices = remove config.networking.hostName (builtins.attrNames share);
        type = attrByPath [ hostname "type" ] "sendreceive" share;
        path = attrByPath [ hostname "path" ] null share;
      }) (filterAttrs (id: share: (hasAttr hostname share)) syncfolders);
    };
  };
}
