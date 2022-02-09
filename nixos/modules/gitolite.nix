{ config, pkgs, ... }:

{
  services.gitolite = {
    enable = true;
    adminPubkey = builtins.head config.users.users.a.openssh.authorizedKeys.keys;
  };
}
