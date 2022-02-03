{ config, pkgs, options, ... }:

{
  environment.systemPackages = with pkgs; [
    elinks
    neomutt
    notmuch
    notmuch-mutt
    msmtp
  ];

  services.offlineimap = {
    enable = true;
    path = [ pkgs.notmuch ];
  };
}
