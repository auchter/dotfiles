{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "pycamilladsp-plot";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "HEnquist";
    repo = "pycamilladsp-plot";
    rev = "442b406b90c4c5132f00dc955213de41370896d1";
    sha256 = "sha256-5hfuYe1RbJm2L/eZo0vt69aOyRuGGG+/C+79e0t4Irk=";
  };

  propagatedBuildInputs = with python3Packages; [
    numpy
    matplotlib
    jsonschema
    pyyaml
    websocket-client
  ];

  meta = with lib; {
    description = "Plotting tools for CamillaDSP";
    homepage = "https://github.com/HEnquist/pycamilladsp-plot";
    maintainers = with maintainers; [ auchter ];
    license = licenses.gpl3Only;
  };
}
