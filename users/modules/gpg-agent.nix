{ config, pkgs, lib, ... }:

{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };
}
