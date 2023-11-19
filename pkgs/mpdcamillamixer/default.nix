{ lib
, pycamilladsp
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "mpdcamillamixer";
  version = "unstable-2023-11-18";

  src = ./src;

  propagatedBuildInputs = with python3Packages; [
    pycamilladsp
    python3Packages.mpd2
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/dotfiles";
    description = "mpdcamillamixer";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
