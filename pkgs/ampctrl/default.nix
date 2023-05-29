{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "ampctrl";
  version = "unstable-2023-06-24";

  src = ./src;

  propagatedBuildInputs = with python3Packages; [
    python3Packages.libgpiod
    python3Packages.mpd2
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/dotfiles";
    description = "ampctrl";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
