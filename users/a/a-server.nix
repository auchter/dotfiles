{ config, pkgs, lib, ...}:

{
  imports = [
    ./common.nix
    ../modules/tmux.nix
    ../modules/viddy.nix
    ../modules/zsh.nix
  ];

  modules.git.enable = true;
  modules.vim.enable = true;
}
