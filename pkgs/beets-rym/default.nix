{ lib
, fetchFromGitHub
, python3Packages
, beets
}:

python3Packages.buildPythonApplication rec {
  pname = "beets-rym";
  version = "unstable-2022-08-15";

  src = /home/a/git/beets-rym;

  nativeBuildInputs = [ beets ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/beets-rym";
    description = "Get info from RYM via Google";
    license = licenses.mit;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
