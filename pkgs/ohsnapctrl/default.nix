{ lib
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "ohsnapctrl";
  version = "unstable-2023-08-13";

  src = ./src;

  propagatedBuildInputs = with python3Packages; [
    python3Packages.libgpiod
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/dotfiles";
    description = "ohsnapctrl";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
