{ lib
, fetchFromGitHub
, python3Packages
, beets
}:

python3Packages.buildPythonApplication rec {
  pname = "beets-importreplace";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "edgars-supe";
    repo = pname;
    rev = "0f8d95abd4da4a8ce589832e3cf769ae9db4340e";
    sha256 = "sha256-PiJ2wYqfAd9XWHIiHO73fOhEIGN2dN+STfC8cQCddd4=";
  };

  nativeBuildInputs = [ beets ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/edgars-supe/beets-importreplace";
    description = "Plugin for beets to perform regex replacements during import";
    license = licenses.mit;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
