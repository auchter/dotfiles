# dotfiles

Managed using Nix flakes and home-manager.

To setup, symlink `flake.nix` to `/etc/nixos/flake.nix`, and run `nixos-rebuild switch`.

To build and remotely deploy, `nixos-rebuild switch` can be used as well.
For example, to build on `localhost` and deploy to `ipos`, run: `nixos-rebuild switch --flake .#ipos --target-host root@ipos --build-host localhost`
