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
  };
in {
  options.modules.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      devices = {
        pixel5a = {
          id = "75SH6AM-BPLJYIT-6AAK5SZ-GG3HC4D-5ZADRYP-GSCA3UM-PBJLV52-IP6JLQ3";
        };
        moloch = {
          id = "RUZLV3F-BEAFDBU-JJQC5R3-GO6GDCR-2SDL4TP-UTTDZYF-5MC5SLY-YVI5OA7";
        };
        stolas = {
          id = "UCSZGQG-YS6QPBH-ZQ7MKTO-IEHYTNC-YUVBBQC-2R4SN27-6KQHSCO-266UDQS";
        };
        malphas = {
          id = "2CKYL2R-NGNKKKU-2IPPQII-C7XPP2I-SJDSE5O-IEXRCS5-WUCG7HF-OPSTVAT";
        };
      };
      folders = mapAttrs (id: share: {
        id = id;
        devices = remove config.networking.hostName (builtins.attrNames share);
        type = attrByPath [ hostname "type" ] "sendreceive" share;
        path = attrByPath [ hostname "path" ] null share;
      }) (filterAttrs (id: share: (hasAttr hostname share)) syncfolders);
    };
  };
}
