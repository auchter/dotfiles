{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "pipewire_python";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "pablodz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-6UIu7vke40q+n91gU8YxwMV/tWjLT6iDmHCMVqnXdMY=";
  };

  format = "pyproject";

  nativeBuildInputs = [ python3Packages.flit-core ];

  meta = with lib; {
    description = "Python controller, player and recorder via pipewire's commands";
    homepage = "https://github.com/pablodz/pipewire_python";
    maintainers = with maintainers; [ auchter ];
    license = licenses.mit;
  };
}
