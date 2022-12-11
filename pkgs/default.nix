{ pkgs ? null }:
{
  beets-dynamicrange = pkgs.callPackage ./beets-dynamicrange { };
  beets-importreplace = pkgs.callPackage ./beets-importreplace { };
  beetstream = pkgs.callPackage ./beetstream { };
  brutefir = pkgs.callPackage ./brutefir { };
  drduh-yubikey-guide = pkgs.callPackage ./drduh-yubikey-guide { };
  dterm = pkgs.callPackage ./dterm { };
  ffts = pkgs.callPackage ./ffts { };
  glscopeclient = pkgs.callPackage ./glscopeclient { };
  kindle-send = pkgs.callPackage ./kindle-send.nix { };
  michauch = pkgs.callPackage ./michauch { };
  mlat-client = pkgs.python3Packages.callPackage ./mlat-client { };
  ot-recorder = pkgs.callPackage ./ot-recorder { };
  panopticon = pkgs.callPackage ./panopticon { };
  pyhifid = pkgs.callPackage ./pyhifid { };
  python-brutefir = pkgs.callPackage ./python-brutefir { };
  python-powermate = pkgs.callPackage ./python-powermate { };
  readsb = pkgs.callPackage ./readsb { };
  screenshot = pkgs.callPackage ./screenshot.nix { };
  tar1090 = pkgs.callPackage ./tar1090 { };
  ws2902-mqtt = pkgs.callPackage ./ws2902-mqtt { };
}
