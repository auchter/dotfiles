{ lib
, fetchFromGitHub
, python3Packages
, python-brutefir
, python-powermate
}:

python3Packages.buildPythonApplication rec {
  pname = "pyhifid";
  version = "unstable-2022-10-24";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "47ce8692e3ad7f8f98baf79562ac3ba01723b9bd";
    sha256 = "sha256-CObfZjxHvHZ7yHdCPDsRvRBg4WQhp9//+0wHTFvP4wo=";
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
