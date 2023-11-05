{ pkgs ? null }:
{
  nodejs_asar = pkgs.nodePackages.asar;
  ampctrl = pkgs.callPackage ./ampctrl { };
  beets-dynamicrange = pkgs.callPackage ./beets-dynamicrange { };
  beets-importreplace = pkgs.callPackage ./beets-importreplace { };
  beets-rym = pkgs.callPackage ./beets-rym { };
  beetstream = pkgs.callPackage ./beetstream { };
  brutefir = pkgs.callPackage ./brutefir { };
  cal-add = pkgs.callPackage ./cal-add.nix { };
  camilladsp = pkgs.callPackage ./camilladsp { };
  camillagui = pkgs.callPackage ./camillagui { };
  drduh-yubikey-guide = pkgs.callPackage ./drduh-yubikey-guide { };
  dterm = pkgs.callPackage ./dterm { };
  ffts = pkgs.callPackage ./ffts { };
  glscopeclient = pkgs.callPackage ./glscopeclient { };
  kindle-send = pkgs.callPackage ./kindle-send.nix { };
  libupnpp = pkgs.callPackage ./libupnpp { };
  listenbrainz-mpd = pkgs.callPackage ./listenbrainz-mpd { };
  mcg = pkgs.callPackage ./mcg { };
  michauch = pkgs.callPackage ./michauch { };
  mlat-client = pkgs.python3Packages.callPackage ./mlat-client { };
  mpdpower = pkgs.callPackage ./mpdpower { };
  npupnp = pkgs.callPackage ./npupnp { };
  ohsnapctrl = pkgs.callPackage ./ohsnapctrl { };
  ot-recorder = pkgs.callPackage ./ot-recorder { };
  panopticon = pkgs.callPackage ./panopticon { };
  pycamilladsp = pkgs.callPackage ./pycamilladsp { };
  pycamilladsp-plot = pkgs.callPackage ./pycamilladsp-plot { };
  pylistenbrainz = pkgs.callPackage ./pylistenbrainz { };
  python-brutefir = pkgs.callPackage ./python-brutefir { };
  python-powermate = pkgs.callPackage ./python-powermate { };
  readsb = pkgs.callPackage ./readsb { };
  screenshot = pkgs.callPackage ./screenshot.nix { };
  tar1090 = pkgs.callPackage ./tar1090 { };
  upmpdcli = pkgs.callPackage ./upmpdcli { };
  ws2902-mqtt = pkgs.callPackage ./ws2902-mqtt { };
}
