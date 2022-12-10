{ lib
, writeShellApplication
, grim
, slurp
}:

writeShellApplication {
  name = "screenshot";
  runtimeInputs = [ grim slurp ];

  text = ''
    slurp | grim -g -
  '';
}

