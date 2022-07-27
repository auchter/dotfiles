{ nixpkgs, ... }:
let
  additions = final: prev: import ../pkgs { pkgs = prev; };
in
  nixpkgs.lib.composeManyExtensions [ additions ]
