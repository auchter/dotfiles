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
    rev = "4d084b5ebe75b61af9fec7ba2cada61f4da4d214";
    sha256 = "sha256-1a+T3wnlppxgDIxw6i7OrvAisbjPMjdvHQgC4sXfsuY=";
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
