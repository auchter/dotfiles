{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    home-manager.url = "github:rycee/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      moloch = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-moloch.nix;
            home-manager.users.guest = import ./users/guest.nix;
          }
          ./systems/moloch/configuration.nix
        ];
      };
      ipos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-server.nix;
          }
          ./systems/ipos/configuration.nix
        ];
      };
      stolas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-server.nix;
          }
          ./systems/stolas/configuration.nix
        ];
      };
      orobas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./users/a/a-server.nix;
          }
          ./systems/orobas/configuration.nix
        ];
      };
    };
  };
}
