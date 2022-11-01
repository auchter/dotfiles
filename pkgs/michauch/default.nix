{ lib
, stdenv
, fetchFromGitHub
, pandoc
, rsync
}:

stdenv.mkDerivation rec {
  pname = "michau.ch";
  version = "unstable-2022-10-30";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "7166b10d5df02365e7aa9269b5ba02393e8a13aa";
    sha256 = "sha256-slgimRft5cmgI81IAwuY1X4lFKC5ILa1MDyUGc2Vooo=";
  };

  buildInputs = [
    pandoc
    rsync
  ];

  installPhase = ''
    runHook preInstall

    bash build $out

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/auchter/michau.ch";
    description = "https://michau.ch";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
