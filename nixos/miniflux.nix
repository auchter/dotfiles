{ config, pkgs, options, ... }:

{
  environment.systemPackages = with pkgs; [
    miniflux
  ];

  services.miniflux = {
    enable = true;
    config = {
      CLEANUP_FREQUENCY = "48";
      LISTEN_ADDR = "localhost:9111";
    };
  };
}
