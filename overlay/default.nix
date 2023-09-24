{ nixpkgs, ... }:
let
  additions = _final: prev: import ../pkgs { pkgs = prev; };
  mopidy-subidy = final: prev: import ./mopidy-subidy.nix { inherit final; inherit prev; };
  nodePackages.readability-cli = final: prev: import ./readability-cli.nix { inherit final; inherit prev; };
  raspberrypiWirelessFirmware = final: prev: import ./raspberrypi-wireless { inherit final; inherit prev; };
  cdrdao = final: prev: import ./cdrdao.nix { inherit final; inherit prev; };
  signal-desktop = final: prev: import ./signal-desktop.nix { inherit final; inherit prev; };
in
  nixpkgs.lib.composeManyExtensions [
    additions
    # cdrdao # Removing
    mopidy-subidy
    nodePackages.readability-cli
    raspberrypiWirelessFirmware
    signal-desktop
  ]
