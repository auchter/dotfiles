{ lib
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
    rev = "28150a1d043a6777ef071171b171644f111abd77";
    sha256 = "sha256-pmEXYzKw55kLDL74Hamj6oar4TPPDe+uyZToy1+PuvU=";
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
