{ pkgs ? null }:
{
  brutefir = pkgs.callPackage ./brutefir { };
  drduh-yubikey-guide = pkgs.callPackage ./drduh-yubikey-guide { };
  dterm = pkgs.callPackage ./dterm { };
  ffts = pkgs.callPackage ./ffts { };
  glscopeclient = pkgs.callPackage ./glscopeclient { };
  mlat-client = pkgs.python3Packages.callPackage ./mlat-client { };
  panopticon = pkgs.callPackage ./panopticon { };
  pyhifid = pkgs.callPackage ./pyhifid { };
  python-brutefir = pkgs.callPackage ./python-brutefir { };
  python-powermate = pkgs.callPackage ./python-powermate { };
  readsb = pkgs.callPackage ./readsb { };
  tar1090 = pkgs.callPackage ./tar1090 { };
  ws2902-mqtt = pkgs.callPackage ./ws2902-mqtt { };
}
