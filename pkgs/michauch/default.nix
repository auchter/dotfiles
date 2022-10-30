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
    rev = "8436b7e49104bc3c936e2f3f5a94a2855ed4dcd9";
    sha256 = "sha256-lA05ZtNMFRETaswD91lQmFbdHMq1meEfq9s8xKCuNzY=";
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
