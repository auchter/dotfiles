{ lib
, fetchFromGitHub
, buildPythonApplication
}:

buildPythonApplication rec {
  pname = "mlat-client";
  version = "unstable-2022-06-27";

  src = fetchFromGitHub {
    owner = "adsbxchange";
    repo = pname;
    rev = "55fcde6fcf4216a33006e40ad17dbb924d65f6df";
    sha256 = "sha256-94D9/ZQUtLR79XDsMtKVAeNhNyOCwv+jct0ruVBmLGA=";
  };

  meta = with lib; {
    homepage = "https://github.com/adsbxchange/mlat-client";
    description = "Client for Mode S multilateration";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ auchter ];
  };
}
