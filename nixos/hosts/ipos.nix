{ config, pkgs, ... }:

{
  networking.useDHCP = false;
  networking.interfaces.enp0s4.useDHCP = true;

  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial
    terminal_output serial
  '';

  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;
}
