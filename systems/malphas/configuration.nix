{ config, pkgs, ... }:

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
    {
      name = "delta1-overlay";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@0 {
            target = <&i2c0>;
            __overlay__ {
              status = "okay";
              delta1_set: gpio@3f {
                compatible = "nxp,pcf8574a";
                reg = <0x3f>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA1_SET_0",
                                  "DELTA1_SET_1",
                                  "DELTA1_SET_2",
                                  "DELTA1_SET_3",
                                  "DELTA1_SET_4",
                                  "DELTA1_SET_5",
                                  "DELTA1_SET_6",
                                  "DELTA1_SET_7";
              };

              delta1_rst: gpio@3e {
                compatible = "nxp,pcf8574a";
                reg = <0x3e>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA1_RST_0",
                                  "DELTA1_RST_1",
                                  "DELTA1_RST_2",
                                  "DELTA1_RST_3",
                                  "DELTA1_RST_4",
                                  "DELTA1_RST_5",
                                  "DELTA1_RST_6",
                                  "DELTA1_RST_7";
              };
            };
          };
        };
      '';
    }
    {
      name = "delta2-overlay";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@0 {
            target = <&i2c0>;
            __overlay__ {
              status = "okay";
              delta2_set: gpio@3d {
                compatible = "nxp,pcf8574a";
                reg = <0x3d>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA2_SET_0",
                                  "DELTA2_SET_1",
                                  "DELTA2_SET_2",
                                  "DELTA2_SET_3",
                                  "DELTA2_SET_4",
                                  "DELTA2_SET_5",
                                  "DELTA2_SET_6",
                                  "DELTA2_SET_7";
              };

              delta2_rst: gpio@3c {
                compatible = "nxp,pcf8574a";
                reg = <0x3c>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA2_RST_0",
                                  "DELTA2_RST_1",
                                  "DELTA2_RST_2",
                                  "DELTA2_RST_3",
                                  "DELTA2_RST_4",
                                  "DELTA2_RST_5",
                                  "DELTA2_RST_6",
                                  "DELTA2_RST_7";
              };
            };
          };
        };
      '';
    }
  ];

  system.stateVersion = "22.05"; # Did you read the comment?
}

