{ nixpkgs, ... }:
let
  additions = _final: prev: import ../pkgs { pkgs = prev; };
  mopidy-subidy = final: prev: import ./mopidy-subidy.nix { inherit final; inherit prev; };
  nodePackages.readability-cli = final: prev: import ./readability-cli.nix { inherit final; inherit prev; };
  raspberrypiWirelessFirmware = final: prev: import ./raspberrypi-wireless { inherit final; inherit prev; };
  snapcast = final: prev: import ./snapcast { inherit final; inherit prev; };
in
  nixpkgs.lib.composeManyExtensions [
    additions
    mopidy-subidy
    nodePackages.readability-cli
    raspberrypiWirelessFirmware
    snapcast
  ]
