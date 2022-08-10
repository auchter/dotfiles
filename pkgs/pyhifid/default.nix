{ lib
, stdenv
, fetchFromGitHub
, python3Packages
, python-brutefir
, python-powermate
}:

python3Packages.buildPythonApplication rec {
  pname = "pyhifid";
  version = "unstable-2022-05-26";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "0967766447d4ff51760603aa3b811d678eb3dfd6";
    sha256 = "sha256-/l+9NiZ/xKcU/1kUhn+H1ASWTb74NMDeVyJqQhRSAsI=";
  };

  propagatedBuildInputs = with python3Packages; [
    flask
    flask-restful
    gevent
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
