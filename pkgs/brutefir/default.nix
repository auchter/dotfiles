{ lib, stdenv, fetchurl, alsa-lib, fftw, fftwFloat, flex, libjack2 }:

stdenv.mkDerivation rec {
  pname = "brutefir";
  version = "1.0o";

  src = fetchurl {
    url = "https://torger.se/anders/files/brutefir-${version}.tar.gz";
    sha256 = "caae4a933b53b55b29d6cb7e2803e20819f31def6d0e4e12f9a48351e6dbbe9f";
  };

  nativeBuildInputs = [ flex ];

  buildInputs = [
    alsa-lib
    fftw
    fftwFloat
    libjack2
  ];

  patches = [
    ./0001-Remove-platform-conditionals.patch
    ./0002-Remove-unnecessary-lib-include-path-changes.patch
    ./0003-Specify-whether-to-build-alsa-oss-jack-via-Make-opti.patch
  ];

  postPatch = "substituteInPlace bfconf.c --replace /usr/local $out";

  makeFlags = [
    "BRUTEFIR_ALSA=yes"
    "BRUTEFIR_OSS=yes"
    "BRUTEFIR_JACK=yes"
  ] ++ lib.optional (!stdenv.targetPlatform.isAarch64) "ARCH=x86";

  installFlags = [ "INSTALL_PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://torger.se/anders/brutefir.html";
    description = "A software convolution engine";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ auchter ];
    platforms = [ "aarch64-linux" "x86_64-linux" "i686-linux" ];
  };
}
