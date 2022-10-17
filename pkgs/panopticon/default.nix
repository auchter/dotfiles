{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "panopticon";
  version = "unstable-2022-08-04";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "912f9bba9c43de787068d1b2e95a4b10a37efdfe";
    sha256 = "sha256-Osg2FDbjm1FlDs/evfNZ5aSgd21JR4QelS8wgoEDG+k=";
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
