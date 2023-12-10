{ lib
, pipewire_python
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "ttctrl";
  version = "unstable-2023-12-10";

  src = ./src;

  propagatedBuildInputs = with python3Packages; [
    python3Packages.mpd2
    pipewire_python
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/dotfiles";
    description = "ttctrl";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
