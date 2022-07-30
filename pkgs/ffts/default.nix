{ stdenv
, lib
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "ffts";
  version = "unstable-2017-06-17";

  src = fetchFromGitHub {
    owner = "anthonix";
    repo = "ffts";
    rev = "fe86885ecafd0d16eb122f3212403d1d5a86e24e";
    sha256 = "sha256-arBXkEbKGd0y6XpyynUSFQmNs7fndhEK7y1NNZI9MnI=";
  };

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DENABLE_SHARED=ON" ];

  meta = with lib; {
    description = "Fastest Fourier Transform in the South library";
    homepage = "https://github.com/anthonix/ffts";
    license = licenses.bsd3;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.unix;
  };
}
