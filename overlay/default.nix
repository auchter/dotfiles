{ nixpkgs, ... }:
let
  additions = final: prev: import ../pkgs { pkgs = prev; };
  snapcast = final: prev: import ./snapcast { inherit final; inherit prev; };
in
  nixpkgs.lib.composeManyExtensions [ additions snapcast ]
