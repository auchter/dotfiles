{ lib, stdenv
, fetchFromGitHub
, pkg-config
, libusb1
, ncurses
, rtl-sdr
, zlib
, zstd
, writeText
}:

stdenv.mkDerivation rec {
  pname = "readsb";
  version = "unstable-2022-07-10";

  src = fetchFromGitHub {
    owner = "wiedehopf";
    repo = pname;
    rev = "b9884097dca1325eff09777cf20db0e0f4933c14";
    sha256 = "sha256-zYUIRbbtZazuMb8u+GT7Kq4ICnlOjnCCrUWO+1ZBWIU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libusb1
    ncurses
    rtl-sdr
    zlib
    zstd
  ];

  postPatch = ''
    echo ${src.rev} > READSB_VERSION
  '';

  makeFlags = [
    "RTLSDR=yes"
  ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -v readsb $out/bin
    cp -v viewadsb $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    broken = stdenv.isDarwin;
    description = "A Mode-S/ADSB/TIS decoder for RTLSDR, BladeRF, Modes-Beast and GNS5894 devices";
    homepage = "https://github.com/wiedehopf/readsb";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ auchter ];
  };
}
