{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    #nixpkgs.url = "path:/home/a/git/nixpkgs";
    home-manager.url = "github:rycee/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, home-manager, sops-nix, rust-overlay, ... }:
  let
    mkSystem = hostname: hardware: nixpkgs.lib.nixosSystem rec {
      system = {
        "generic-x86_64" = "x86_64-linux";
        "pine64-pineH64B" = "aarch64-linux";
        "raspberryPi-aarch64" = "aarch64-linux";
      }."${hardware}";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron-25.9.0" ];
        };
        overlays = [
          (import ./overlay { inherit nixpkgs; })
          rust-overlay.overlays.default
        ];
      };
      modules = [
        { networking.hostName = hostname; }
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.sharedModules = builtins.attrValues (import ./modules/home-manager);
          home-manager.users.a = nixpkgs.lib.mkMerge ([
            (import (./users/a.nix))
          ] ++
            (let
              path = ./. + "/systems/${hostname}/home.nix";
            in nixpkgs.lib.optional (builtins.pathExists path) (import path))
          );
        }
        (./. + "/systems/${hostname}/configuration.nix")
        sops-nix.nixosModules.sops
        (./. + "/hardware/${hardware}")
      ] ++ (builtins.attrValues (import ./modules/nixos));
    };
  in
  {
    nixosModules = {
      home-manager = builtins.attrValues (import ./modules/home-manager);
    };
    nixosConfigurations = {
      ## For aarch64-linux systems:
      # nix build .#nixosConfigurations.balan.config.system.build.sdImage

      moloch = mkSystem "moloch" "generic-x86_64";
      ipos = mkSystem "ipos" "generic-x86_64";
      stolas = mkSystem "stolas" "generic-x86_64";
      orobas = mkSystem "orobas" "generic-x86_64";
      volac = mkSystem "volac" "generic-x86_64";
      malphas = mkSystem "malphas" "pine64-pineH64B";
      balan = mkSystem "balan" "pine64-pineH64B";
      andras = mkSystem "andras" "raspberryPi-aarch64";
      agares = mkSystem "agares" "generic-x86_64";
      azazel = mkSystem "azazel" "generic-x86_64";

      ## nix build .#nixosConfigurations.gpg-provision.config.system.build.isoImage
      gpg-provision = mkSystem "gpg-provision" "generic-x86_64";
    };
  };
}
