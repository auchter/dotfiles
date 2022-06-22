{ config, pkgs, lib, ...}:

{
  imports = [
    ./common.nix
    ../modules/git.nix
    ../modules/tmux.nix
    ../modules/viddy.nix
    ../modules/vim.nix
    ../modules/zsh.nix
  ];
}
