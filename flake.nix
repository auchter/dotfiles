{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    home-manager.url = "github:rycee/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      "a@moloch" = home-manager.lib.homeManagerConfiguration {
        username = "a";
        homeDirectory = "/home/a";
        system = "x86_64-linux";
        configuration = import ./home-manager/moloch.nix;
        stateVersion = "21.11";
      };
    };

    nixosConfigurations = {
      moloch = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.users.a = import ./home-manager/moloch.nix;
            home-manager.users.guest = import ./home-manager/guest.nix;
          }
          ./nixos/configuration.moloch.nix
        ];
      };
    };
  };
}
