{ lib
, python3
, brutefir
}:

python3.pkgs.buildPythonPackage rec {
  pname = "brutefir";
  version = "0.0.2";

  # since we're lacking a setup.py:
  format = "pyproject";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-PxioYEH3t2HgGtc5BtKwRD7ar88s7J9Fm5pA+I+DCUo=";
  };

  propagatedBuildInputs = with python3.pkgs; [
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