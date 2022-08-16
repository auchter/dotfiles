{ lib
, stdenv
, fetchFromGitHub
, python3Packages
, beets
, dr14_tmeter
}:

python3Packages.buildPythonApplication rec {
  pname = "beets-dynamicrange";
  version = "unstable-2022-08-15";

  src = fetchFromGitHub {
    owner = "auchter";
    repo = pname;
    rev = "a3f789bb726209a47ff845ddf95023ae631726b5";
    sha256 = "sha256-En3F1bOJm3phOGM5nEGK4bx5LvX+xG9iuzgaqX1icQo=";
  };

  nativeBuildInputs = [ beets ];

  propagatedBuildInputs = [ dr14_tmeter ];

  postPatch = ''
    substituteInPlace beetsplug/dynamicrange.py \
      --replace dr14_tmeter ${dr14_tmeter}/bin/dr14_tmeter
  '';

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/beets-dynamicrange";
    description = "Calculate and store dynamic range of music for beets";
    license = licenses.mit;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
