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
      postPatch = ''
        substituteInPlace client/brutefir.cpp --replace \
          'bp::search_path("brutefir");' 'boost::filesystem::path("${final.brutefir}/bin/brutefir");'
      '';
    });
  };
in
  nixpkgs.lib.composeManyExtensions [ additions snapcast ]
