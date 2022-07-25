{
  inputs = {
    nixpkgs.url = "github:auchter/nixpkgs/auchter-22.05";
    home-manager.url = "github:auchter/home-manager/auchter-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
  let
    mkSystem = hostname: system: a-flavor:
    nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        {
          networking.hostName = hostname;
        }
        home-manager.nixosModules.home-manager {
          home-manager.users.a = import (./. + "/users/a/a-${a-flavor}.nix");
          home-manager.users.guest = import ./users/guest.nix;
        }
        (./. + "/systems/${hostname}/configuration.nix")
        sops-nix.nixosModules.sops
      ];
    };
  in
  {
    nixosConfigurations = {
      moloch = mkSystem "moloch" "x86_64-linux" "moloch";
      ipos = mkSystem "ipos" "x86_64-linux" "server";
      stolas = mkSystem "stolas" "x86_64-linux" "server";
      orobas = mkSystem "orobas" "x86_64-linux" "server";
      volac = mkSystem "volac" "aarch64-linux" "server";
    };
  };
}
