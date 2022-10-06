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
    rev = "15746f3e44bd9cfca0cdee83402ee159c3b7a4ad";
    sha256 = "sha256-WYVOBnwTpksOKtsiYeJ5o9kdOofOXvlHK+B9y6f2U0Q=";
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
