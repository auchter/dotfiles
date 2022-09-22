{ nixpkgs, ... }:
let
  additions = final: prev: import ../pkgs { pkgs = prev; };
  snapcast = final: prev: {
    snapcast = prev.snapcast.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ./snapcast/0001-Hack-in-BruteFIR-support.patch
        ./snapcast/0002-Add-brutefir_config-option.patch
        ./snapcast/0003-include-missing-headers.patch
      ];
    });
  };
in
  nixpkgs.lib.composeManyExtensions [ additions snapcast ]
