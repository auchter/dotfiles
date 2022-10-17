{ ...}:

{
  home.username = "a";
  home.homeDirectory = "/home/a";
  home.stateVersion = "21.11";

  programs.git = {
    userName = "Michael Auchter";
    userEmail = "a@phire.org";
  };

  programs.home-manager.enable = true;

  modules.git.enable = true;
  modules.tmux.enable = true;
  modules.vim.enable = true;
  modules.zsh.enable = true;
}

