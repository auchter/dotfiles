{
  inputs = {
    #nixpkgs.url = "path:/home/a/git/nixpkgs";
    #nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs.url = "github:auchter/nixpkgs/auchter-22.05";
    home-manager.url = "github:rycee/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }: {
    nixosConfigurations = {
      moloch = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-moloch.nix;
            home-manager.users.guest = import ./users/guest.nix;
          }
          ./systems/moloch/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
      ipos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-server.nix;
          }
          ./systems/ipos/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
      stolas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-server.nix;
          }
          ./systems/stolas/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
      orobas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-server.nix;
          }
          ./systems/orobas/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
