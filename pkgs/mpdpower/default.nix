{ lib
, python-powermate
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "mpdpower";
  version = "unstable-2023-08-20";

  src = ./src;

  propagatedBuildInputs = with python3Packages; [
    python-powermate
    python3Packages.mpd2
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/dotfiles";
    description = "mpdpower";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
