{ config, pkgs, lib, ...}:

{
  home.packages = with pkgs; [
    himitsu
    himitsu-firefox
    hiprompt-gtk-py
    keyring
  ];

  home.file.".mozilla/native-messaging-hosts/himitsu.json".source =
    "${pkgs.himitsu-firefox}/lib/mozilla/native-messaging-hosts/himitsu.json";

  systemd.user.services.himitsud = {
    Unit = {
      Description = "A secret storage manager";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.himitsu}/bin/himitsud";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "default.target" ]; };
  };
}
