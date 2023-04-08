{ stdenv
, lib
, fetchFromGitLab
, autoconf
, automake
, libtool
, pkg-config
, curl
, libmicrohttpd
, expat
}:

stdenv.mkDerivation rec {
  pname = "npupnp";
  version = "5.0.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "medoc92";
    repo = pname;
    rev = "lib${pname}-v${version}";
    sha256 = "sha256-ajs/bqfgbJdlte5ifxcc2VHpLh+ui36tr38sh+IyCrE=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ];

  buildInputs = [
    curl
    expat
    libmicrohttpd
  ];

  preConfigure = "./autogen.sh";

  meta = with lib; {
    description = "A C++ base UPnP library, derived from Portable UPnP, a.k.a libupnp";
    homepage = "https://framagit.org/medoc92/npupnp";
    license = licenses.bsd3;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.unix;
  };
}
