{ lib
, stdenv
, fetchFromGitHub
, python3Packages
, python-brutefir
, python-powermate
}:

python3Packages.buildPythonApplication rec {
  pname = "pyhifid";
  version = "unstable-2022-10-07";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "1fe6d5c142d5b8ac7bc7b80cc1f5cade7215243b";
    sha256 = "sha256-gQKQDJrCVqoDeIhSenXg1ywcdd+j6dBHHdUEMM4qMqI=";
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
