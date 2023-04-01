{ lib
, fetchFromGitHub
, python3Packages
, pylistenbrainz
}:

python3Packages.buildPythonApplication rec {
  pname = "beetstream";
  version = "v1.0.2";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = "Beetstream";
    rev = "093ca0d6877af7bd1ba4bec4ec0c25e0dc979df1";
    sha256 = "sha256-InddISNgTzZk6sYLGlhNoQPW5f9VNc3+3go9Y7PBJLo=";
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
    pylistenbrainz
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

