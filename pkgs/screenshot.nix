{ lib
, writeShellApplication
, grim
, slurp
}:

writeShellApplication {
  name = "screenshot";
  runtimeInputs = [ grim slurp ];

  text = ''
    dir="$HOME/Pictures/screenshots"
    mkdir -p "$dir"
    slurp | grim -g - "$dir/$(date +'%Y%m%d_%Hh%Mm%Ss')_$(hostname)_grim.png"
  '';
}

