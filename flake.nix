{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    #nixpkgs.url = "path:/home/a/git/nixpkgs";
    home-manager.url = "github:rycee/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
  let
    mkSystem = hostname: system: hardware: nixpkgs.lib.nixosSystem {
      system = system;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./overlay { inherit nixpkgs; }) ];
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
    nixosConfigurations = {
      ## For aarch64-linux systems:
      # nix build .#nixosConfigurations.balan.config.system.build.sdImage

      moloch = mkSystem "moloch" "x86_64-linux" "generic";
      ipos = mkSystem "ipos" "x86_64-linux" "generic";
      stolas = mkSystem "stolas" "x86_64-linux" "generic";
      orobas = mkSystem "orobas" "x86_64-linux" "generic";
      volac = mkSystem "volac" "aarch64-linux" "pine64-pineH64B";
      malphas = mkSystem "malphas" "aarch64-linux" "pine64-pineH64B";
      balan = mkSystem "balan" "aarch64-linux" "pine64-pineH64B";

      flaga = mkSystem "flaga" "aarch64-linux" "raspberryPi-aarch64";

      ## nix build .#nixosConfigurations.gpg-provision.config.system.build.isoImage
      gpg-provision = mkSystem "gpg-provision" "x86_64-linux";
    };
  };
}
