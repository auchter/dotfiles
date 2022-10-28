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
    rev = "b1b7fbb4fe4171e3e132e0a2febe6aa94ed5af20";
    sha256 = "sha256-YRPxVqqoWvPMmnuMZhMBOBv+7GdFXI8lJLjfUtCOdOM=";
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
