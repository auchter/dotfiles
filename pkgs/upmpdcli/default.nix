{ stdenv
, lib
, fetchFromGitLab
, autoconf
, automake
, libtool
, pkg-config
, npupnp
, libupnpp
, curl
, libmpdclient
, libmicrohttpd
, jsoncpp
}:

stdenv.mkDerivation rec {
  pname = "upmpdcli";
  version = "1.7.7";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "medoc92";
    repo = pname;
    rev = "${pname}-v${version}";
    sha256 = "sha256-sO//MWWW1Nzu49lIdTyNwRdbnQKt2VErI4oeV0YZXd8=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ];

  buildInputs = [
    jsoncpp
    libmicrohttpd
    libmpdclient
    libupnpp
    npupnp
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with lib; {
    description = "An UPnP Audio Media Renderer based on MPD";
    homepage = "https://www.lesbonscomptes.com/upmpdcli/";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.unix;
  };
}
