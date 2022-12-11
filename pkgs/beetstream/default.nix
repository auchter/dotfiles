{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "beetstream";
  version = "v1.0.2";

  src = fetchFromGitHub {
    owner = "BinaryBrain";
    repo = "Beetstream";
    rev = version;
    sha256 = "sha256-xhWXM8pR6EGqi46ciFtzZiQMcEN2eXD3rJJGV+poTIg=";
  };

  format = "pyproject";

  buildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    flask
    flask-cors
    pillow
  ];

  meta = with lib; {
    homepage = "https://github.com/BinaryBrain/Beetstream";
    description = ''
      Beets.io plugin that expose SubSonic API endpoints, allowing you to
      stream your music everywhere
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}

