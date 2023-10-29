{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "pycamilladsp";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "HEnquist";
    repo = "pycamilladsp";
    rev = "4f4859c0dc8c00e2f589dc6cc57cf8d53124c7b3";
    sha256 = "sha256-rxl40qY2RjefuAHbvTVg9mxoEnQhmfGtxZ4SNEIYlew=";
  };

  propagatedBuildInputs = with python3Packages; [
    pyyaml
    websocket-client
  ];

  meta = with lib; {
    description = "Python library for handling the communication with CamillaDSP via a websocket.";
    homepage = "https://github.com/HEnquist/pycamilladsp";
    maintainers = with maintainers; [ auchter ];
    license = licenses.gpl3Only;
  };
}
