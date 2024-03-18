{ ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.interfaces.eth0.useDHCP = true;
  modules.sshd.enable = true;

  sound.enable = true;

  modules.snapclient = {
    enable = true;
    sampleFormat = "44100:16:*";
    soundcard = "front:CARD=adapter,DEV=0";
  };

  services.ohsnapctrl = {
    enable = true;
    gpio = "TRIG_OUT_0";
  };

  hardware.gpio.enable = true;
  hardware.i2c.enable = true;
  hardware.deviceTree.overlays = [
    {
      name = "preamp-line-names";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@0 {
            target = <&pio>;
            __overlay__ {
              gpio-line-names =
                /* A */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* B */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* C */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* D */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "RELAY_PWR", "TRIG_OUT_0", "TRIG_OUT_1", "TRIG_OUT_2", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* E */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* F */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* G */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* H */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "";
            };
          };
        };
      '';
    }
  ];

  system.stateVersion = "22.05"; # Did you read the comment?
}

