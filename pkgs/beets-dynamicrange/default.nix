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
    rev = "59baa2d8136954c7c378815a46b9b3b2f425a692";
    sha256 = "sha256-FeIE86Zfk99qWwAp0/LfrAdBpNyVTk6G09Myef77H8w=";
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
