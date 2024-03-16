{ config, pkgs, ... }:

{

  programs.irssi = {
    enable = true;
    extraConfig = ''
      settings = {
        core = {
          real_name = "xphn";
          user_name = "xphn";
          nick = "xphn";
        };
      };
    '';
    networks = {
      liberachat = {
        nick = "xphn";
        server = {
          address = "irc.libera.chat";
          port = 6697;
          autoConnect = true;
        };
      };
    };
  };
}
