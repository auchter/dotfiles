{ lib
, fetchFromGitHub
, python3Packages
, beets
}:

python3Packages.buildPythonApplication rec {
  pname = "beets-rym";
  version = "unstable-2022-08-15";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "87b249dc42cd90103673f5dec275074521b135ba";
    sha256 = "sha256-Rg4x6Jjd9xoBAz0IBEw4fgGVksEW2gnkCEdPWH3LuM4=";
  };

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
