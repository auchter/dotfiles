{ pkgs, ...}:

{
  home.username = "a";
  home.homeDirectory = "/home/a";
  home.stateVersion = "22.11";

  programs.git = {
    userName = "Michael Auchter";
    userEmail = "a@phire.org";
  };

  programs.home-manager.enable = true;

  modules.git.enable = true;
  modules.tmux.enable = true;
  modules.vim.enable = true;
  modules.zsh.enable = true;
  programs.zsh.enable = true;

  # Note, keep this list small-ish as these will be installed on all systems!
  home.packages = with pkgs; [
    age
    elinks
    htop
    moreutils
    nmap
    sshfs
    unzip
    wget
  ];
}

