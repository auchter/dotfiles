{ config, pkgs, options, ... }:
{
  services = {
      syncthing = {
	  enable = true;
	  user = "a";
	  dataDir = "/home/a/syncthing";
	  configDir = "/home/a/.config/syncthing";
      };
  };
}
