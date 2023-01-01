{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "beetstream";
  version = "v1.0.2";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = "Beetstream";
    rev = "efc1cd3905e740205fbe23132dd89dfd7934c490";
    sha256 = "sha256-KOEqjAEtXYrdkMV8zopTLioAtWOM34oF8D0sr0fGVac=";
  };

  format = "pyproject";

  buildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    flask
    flask-cors
    pillow
    pylast
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

