{ config, pkgs, ... }:

let
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzIue421fOG3rtf/OrysL6lbGYuyavrZtQEPgXNkeYqQmBcHTGBujhXkr6fXVB+l4I2E+eWz+vyDD0JZWYZYeyyFSTS6yArIH+sEdEFzqNjQ+H0td5sEfysZfOkeGSKwNhnSKl5yVFkIn3DE3igCS97CqNBGf2kBLX//BGvgrvGLVvDIv6x0hUhNjHyTcth510sRi3TTcDb+GwNQqHyl9K/gtQFXVNVXg1bxGhzDD+NFARHiaPys6/QHP3N2X6KJV+1L3Of/w2+YLNPhRaJMBw3C4nrNoC/vPbH0m2pO3JhfILW7f7EgZSfp82vEO2XGuKbMc+1tXUaInA6Gy889f1 a@moloch.phire.org"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICrmtSai6pNYXGbJX9BULfF7LpdfYWS/TDBAea27AxZDAAAABHNzaDo= a@moloch"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAII8U1HietB8llpiXaFNhZFxYlbrGjp53U4W/79qOufu4AAAABHNzaDo= a@moloch"
  ];
in
{
  users.users = {
    a = {
      description = "Michael Auchter";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "docker"
        "dialout"
      ];
      home = "/home/a";
      shell = pkgs.zsh;
      uid = 1000;
      openssh.authorizedKeys.keys = keys;
    };

    guest = {
      description = "Guest";
      isNormalUser = true;
      extraGroups = [
        "audio"
        "video"
      ];
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };
}
