{ pkgs ? null }:
{
  brutefir = pkgs.callPackage ./brutefir { };
  drduh-yubikey-guide = pkgs.callPackage ./drduh-yubikey-guide { };
  dterm = pkgs.callPackage ./dterm { };
  ffts = pkgs.callPackage ./ffts { };
  glscopeclient = pkgs.callPackage ./glscopeclient { };
  mlat-client = pkgs.callPackage ./mlat-client { };
  readsb = pkgs.callPackage ./readsb { };
  ws2902-mqtt = pkgs.callPackage ./ws2902-mqtt { };
}
