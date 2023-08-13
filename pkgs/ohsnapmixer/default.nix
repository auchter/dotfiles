{ lib
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "ohsnapmixer";
  version = "unstable-2023-08-13";

  src = ./src;

  propagatedBuildInputs = with python3Packages; [
    python3Packages.libgpiod
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/auchter/dotfiles";
    description = "ohsnapmixer";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
