{ lib
, writeShellApplication
, grim
, slurp
}:

writeShellApplication {
  name = "screenshot";
  runtimeInputs = [ grim slurp ];

  text = ''
    ${slurp}/bin/slurp | ${grim}/bin/grim -g -
  '';
}

