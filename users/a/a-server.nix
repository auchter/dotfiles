{ config, pkgs, lib, ...}:

{
  imports = [
    ./common.nix
    ../modules/git.nix
    ../modules/tmux.nix
    ../modules/viddy.nix
    ../modules/zsh.nix
  ];

  modules.vim.enable = true;
}
