{ config, pkgs, lib, ...}:

{
#  home.packages = with pkgs; [
#    himitsu
#    himitsu-firefox
#    himitsu-keyring
#    hiprompt-gtk-py
#  ];
#
#  home.file.".mozilla/native-messaging-hosts/himitsu.json".source =
#    "${pkgs.himitsu-firefox}/lib/mozilla/native-messaging-hosts/himitsu.json";
#
#  systemd.user.services.himitsud = {
#    Unit = {
#      Description = "A secret storage manager";
#    };
#
#    Service = {
#      Type = "simple";
#      ExecStart = "${pkgs.himitsu}/bin/himitsud";
#      Restart = "on-failure";
#    };
#
#    Install = { WantedBy = [ "default.target" ]; };
#  };
}
