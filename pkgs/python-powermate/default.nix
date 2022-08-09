{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "powermate";
  version = "0.0.2";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-Jb5q6YNcE1B/gUJWGLPlessIb6H0fBhJyXt8IZSd66k=";
  };

  propagatedBuildInputs = with python3.pkgs; [ bluepy ];

  meta = with lib; {
    description = "Library for Griffin Powermate Bluetooth controllers";
    homepage = "https://github.com/auchter/powermate";
    maintainers = with maintainers; [ auchter ];
    license = licenses.mit;
  };
}
