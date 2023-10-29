{ lib
, fetchzip
, python3Packages
, pycamilladsp
, pycamilladsp-plot
}:

python3Packages.buildPythonApplication rec {
  pname = "camillagui";
  version = "1.0.1";

  src = fetchzip {
    url = "https://github.com/HEnquist/camillagui-backend/releases/download/v1.0.1/camillagui.zip";
    stripRoot = false;
    sha256 = "sha256-DrNypW0qSsC/IbqTyTMiCIQ+7r+Q9lpa9snWM3XWjFU=";
  };

  patches = [
    ./0001-Allow-specifying-the-configuration-path.patch
  ];

  format = "other";
  buildPhase = "";
  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
    echo '#!/usr/bin/env python3' > $out/bin/camillagui
    cat $out/bin/main.py >> $out/bin/camillagui
    chmod +x $out/bin/camillagui
    rm $out/bin/main.py
  '';

  propagatedBuildInputs = with python3Packages; [
    aiohttp
    jsonschema
    pycamilladsp
    pycamilladsp-plot
    websocket-client
  ];

  meta = with lib; {
    description = "Backend server for camillagui";
    homepage = "https://github.com/HEnquist/camillagui-backend";
    maintainers = with maintainers; [ auchter ];
    license = licenses.gpl3Only;
  };
}
