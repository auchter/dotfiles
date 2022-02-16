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
        system = "x86_64-linux";
        configuration = "./home-manager/home.nix";
        homeDirectory = "/home/a";
      };
    };

    nixosConfigurations = {
      moloch = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/configuration.moloch.nix ];
      };
    };
  };
}
