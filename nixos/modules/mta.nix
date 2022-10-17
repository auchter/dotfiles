{ config, ... }:

{
  services.postfix = {
    enable = true;
    canonical = ''
      /.+/ nix@phire.org
    '';
    extraConfig = ''
      sender_canonical_classes = envelope_sender
      sender_canonical_maps = regexp:${config.services.postfix.mapFiles.canonical}
    '';
    config = {
      relayhost = "[smtp.migadu.com]:587";
      smtp_sasl_auth_enable = true;
      smtp_sasl_security_options = "noanonymous";
      smtp_use_tls = true;
      # run postmap after creating!
      smtp_sasl_password_maps = "hash:/etc/nixos/private/sasl_passwd";
    };
  };
}
