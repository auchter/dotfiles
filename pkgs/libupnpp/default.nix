{ stdenv
, lib
, fetchFromGitLab
, autoconf
, automake
, libtool
, pkg-config
, npupnp
, curl
, expat
}:

stdenv.mkDerivation rec {
  pname = "libupnpp";
  version = "0.22.4";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "medoc92";
    repo = pname;
    rev = "${pname}-v${version}";
    sha256 = "sha256-Iha8jbTAH0MFP63DUo+HPuvFUgZWyYdZGYbyNsZcJV0=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ];

  propagatedBuildInputs = [
    curl
    npupnp
    expat
  ];

  preConfigure = "./autogen.sh";

  meta = with lib; {
    description = "Libupnpp provides a higher level C++ API over libnpupnp or libupnp.";
    homepage = "https://framagit.org/medoc92/libupnpp";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.unix;
  };
}
