{ lib
, stdenv
, fetchFromGitHub
, python3Packages
, python-brutefir
, python-powermate
}:

python3Packages.buildPythonApplication rec {
  pname = "pyhifid";
  version = "unstable-2022-10-06";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "dda1c2c36454ae83ef093d423f790c1c98806dc3";
    sha256 = "sha256-+FvifHxnCCrCIkuNJV2Y7b7GEVt875fzeZEaddoBH/c=";
  };

  propagatedBuildInputs = with python3Packages; [
    flask
    flask-restful
    gevent
    python3Packages.libgpiod
    paho-mqtt
    python-brutefir
    python-powermate
    requests
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/pyhifid";
    description = "pyhifid";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
