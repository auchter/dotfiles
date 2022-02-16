{ config, pkgs, ... }:

let
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzIue421fOG3rtf/OrysL6lbGYuyavrZtQEPgXNkeYqQmBcHTGBujhXkr6fXVB+l4I2E+eWz+vyDD0JZWYZYeyyFSTS6yArIH+sEdEFzqNjQ+H0td5sEfysZfOkeGSKwNhnSKl5yVFkIn3DE3igCS97CqNBGf2kBLX//BGvgrvGLVvDIv6x0hUhNjHyTcth510sRi3TTcDb+GwNQqHyl9K/gtQFXVNVXg1bxGhzDD+NFARHiaPys6/QHP3N2X6KJV+1L3Of/w2+YLNPhRaJMBw3C4nrNoC/vPbH0m2pO3JhfILW7f7EgZSfp82vEO2XGuKbMc+1tXUaInA6Gy889f1 a@moloch.phire.org"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICrmtSai6pNYXGbJX9BULfF7LpdfYWS/TDBAea27AxZDAAAABHNzaDo= a@moloch"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAII8U1HietB8llpiXaFNhZFxYlbrGjp53U4W/79qOufu4AAAABHNzaDo= a@moloch"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFPyBOa7n5j3m7GRSsqzR6jHCRIrDfn6x0a2VNcC8/IV16QZBi++NYtseZdKL6eelyRHKZ2eQMx7PLEHGkpS0RNT0MSzKOKWYze9lbjByVR3BeFsqx29DUr6Ryk6XMu6nI09vP2FTtQFt81Gjg5QP95wyiJ4xOaPXN31Tu927F90cpzWKaOkruwETV4/AZWNr5QxX68kTfEesqs4XfWbjQyY3ZvcCWMEd4z4sRwG4QMLKrrascFkfrg+Wv1xYA+MISGNdbKOa0hwxqFwDhaMcPErdSrg9UIJBBBgyRPs4enCKiixZ3eeFjlUDP4Df8SWTIf8Zen8rlFmSI8Bz5Un0utFfIKUq+yDhuarlhZxw/MkEaz2pL1OudApMM0K2t6XagHahQG/oimU4jq0uwBgcjsJboP6hpo6TVHHlKrE6EIRS4kkypIJN2PUHGQRB8zMV6WY9o6+492bKN9D3OfPgNAbC9ya27TWrMxEFDiWXmkHxH0aVtHPKHiRaTmc6SRnz4F+7GZpWs9wOyAITGPmTQJ+pgWHp+TKm0OcMptPtnlYYeRpRXi+mnqgK/BgpUkPV4eqzGr6rJ/UZbb4LxyiFGuh2akQdW2YnuZ+UDizSK1FllueSyeuuK8/EU072cro7//+f/i6/S4Uj3kwqLC6JwPztA1iIBlsVyDB5Y+RJy3w== cardno:000616259621"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFPyBOa7n5j3m7GRSsqzR6jHCRIrDfn6x0a2VNcC8/IV16QZBi++NYtseZdKL6eelyRHKZ2eQMx7PLEHGkpS0RNT0MSzKOKWYze9lbjByVR3BeFsqx29DUr6Ryk6XMu6nI09vP2FTtQFt81Gjg5QP95wyiJ4xOaPXN31Tu927F90cpzWKaOkruwETV4/AZWNr5QxX68kTfEesqs4XfWbjQyY3ZvcCWMEd4z4sRwG4QMLKrrascFkfrg+Wv1xYA+MISGNdbKOa0hwxqFwDhaMcPErdSrg9UIJBBBgyRPs4enCKiixZ3eeFjlUDP4Df8SWTIf8Zen8rlFmSI8Bz5Un0utFfIKUq+yDhuarlhZxw/MkEaz2pL1OudApMM0K2t6XagHahQG/oimU4jq0uwBgcjsJboP6hpo6TVHHlKrE6EIRS4kkypIJN2PUHGQRB8zMV6WY9o6+492bKN9D3OfPgNAbC9ya27TWrMxEFDiWXmkHxH0aVtHPKHiRaTmc6SRnz4F+7GZpWs9wOyAITGPmTQJ+pgWHp+TKm0OcMptPtnlYYeRpRXi+mnqgK/BgpUkPV4eqzGr6rJ/UZbb4LxyiFGuh2akQdW2YnuZ+UDizSK1FllueSyeuuK8/EU072cro7//+f/i6/S4Uj3kwqLC6JwPztA1iIBlsVyDB5Y+RJy3w== cardno:000616259529"
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
      uid = 1001;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };
}
