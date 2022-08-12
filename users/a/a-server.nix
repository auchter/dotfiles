{ config, pkgs, lib, ...}:

{
  imports = [
    ./common.nix
    ../modules/viddy.nix
  ];

  modules.git.enable = true;
  modules.tmux.enable = true;
  modules.vim.enable = true;
  modules.zsh.enable = true;
}
