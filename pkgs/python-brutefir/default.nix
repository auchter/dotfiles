{ lib
, fetchFromGitHub
, python3Packages
, brutefir
}:

python3Packages.buildPythonPackage rec {
  pname = "brutefir";
  version = "0.0.5";

  # since we're lacking a setup.py:
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = "python-brutefir";
    rev = "1ad8d7fb153452c179c18f523d92c2360c7766de";
    sha256 = "sha256-23Qhfxk6trJ3LUXD7Y7sfZjthJrXp3jNrSp8ZnIGlQc=";
  };

  buildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    brutefir
    numpy
    pexpect
    pyyaml
    scipy
    voluptuous
  ];

  meta = with lib; {
    description = "Python interface to BruteFIR's command-line interface";
    homepage = "https://github.com/auchter/python-brutefir";
    maintainers = with maintainers; [ auchter ];
    license = licenses.mit;
  };
}
