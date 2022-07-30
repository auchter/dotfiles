{ lib
, stdenv
, fetchFromGitHub
, gawk
, gnused
, gzip
, jq
, wget
}:

stdenv.mkDerivation rec {
  pname = "tar1090";
  version = "unstable-2022-07-12";

  src = fetchFromGitHub {
    owner = "wiedehopf";
    repo = pname;
    rev = "ea9ac54751a8ed337f1b46d86d90d8730fe9b5e9";
    sha256 = "sha256-OwZYeH0TjXFxp6CF/JeN+oriRt9QqEVAO93NPSAv0YI=";
  };

  buildInputs = [
    gawk
    gnused
    gzip
    wget
  ];

  prePatch = ''
    substituteInPlace tar1090.sh \
      --replace "awk" "${gawk}/bin/gawk" \
      --replace "gzip" "${gzip}/bin/gzip" \
      --replace "jq" "${jq}/bin/jq" \
      --replace "sed" "${gnused}/bin/sed" \
      --replace "wget" "${wget}/bin/wget" \
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share $out/bin
    cp tar1090.sh $out/bin
    cp -r html/* $out/share

    runHook postInstall
  '';

  meta = with lib; {
    description = "Web interface for ADS-B decoders such as readsb / dump1090";
    homepage = "https://github.com/wiedehopf/tar1090";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
