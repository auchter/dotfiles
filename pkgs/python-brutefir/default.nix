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
    rev = "b124cb3f3a1e6f4fa613751085eafeae29b6f5e2";
    sha256 = "sha256-NeeVOc2GgndsfML3VrP3lN6cxNfljpxdeKMSfOlFXXs=";
  };

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
