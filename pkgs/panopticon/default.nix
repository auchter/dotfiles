{ lib
, stdenv
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "panopticon";
  version = "unstable-2022-08-04";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "31eda7118f0219b420da09340cb0a7f316b95feb";
    sha256 = "sha256-/j5dtWNdDZmLBfferVkSOVIZOZ4PbXGtyUAR3PH+608=";
  };

  propagatedBuildInputs = with python3Packages; [
    flask
    gevent
    requests
    setuptools
    pillow
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/panopticon";
    description = "They're always watching, you know.";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
