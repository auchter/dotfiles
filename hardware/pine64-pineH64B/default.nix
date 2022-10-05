{ config, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = 7;

  sdImage = {
    # Using Tow-Boot, so no firmware needed here.
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
