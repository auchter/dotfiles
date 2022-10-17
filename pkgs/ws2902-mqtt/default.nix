{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "ws2902-mqtt";
  version = "unstable-2022-07-14";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "5d075f40b0ef14d27b565c13408b13dca10f771a";
    sha256 = "sha256-Vo8iVamaCpYJzj4RZq641rCL7QaOJRAi7mgvdBCPTW4=";
  };

  propagatedBuildInputs = with python3Packages; [
    flask
    gevent
    paho-mqtt
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/ws2902-mqtt";
    description = "WS-2902 Weather Station MQTT Bridge for Home-Assistant";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
