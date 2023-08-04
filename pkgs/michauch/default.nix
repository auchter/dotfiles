{ lib
, stdenv
, fetchFromGitHub
, pandoc
, rsync
}:

stdenv.mkDerivation rec {
  pname = "michau.ch";
  version = "unstable-2022-10-30";

  src = ./src;

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
