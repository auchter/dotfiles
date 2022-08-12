{ config, pkgs, lib, ...}:

{
  imports = [
    ./common.nix
    ../modules/tmux.nix
    ../modules/viddy.nix
  ];

  modules.git.enable = true;
  modules.vim.enable = true;
  modules.zsh.enable = true;
}
