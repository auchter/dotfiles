{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapGAppsHook
, catch2
, clfft
, ffts
, glew
, glm
, gtkmm3
, liblxi
, libsigcxx
, libyamlcpp
, ocl-icd
, opencl-clhpp
, opencl-headers
}:

stdenv.mkDerivation {
  name = "glscopeclient";
  version = "unstable-2022-06-28";

  src = fetchFromGitHub {
    owner = "glscopeclient";
    repo = "scopehal-apps";
    rev = "e378443617214be1fd9d38bbfe9bbc51de5dad3f";
    sha256 = "sha256-GoGixbVzS+PCx+4NMzw/Ouyr9GA6/2Ztxxp0Im5thYc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    catch2
    clfft
    ffts
    glew
    glm
    gtkmm3
    liblxi
    libsigcxx
    libyamlcpp
    ocl-icd
    opencl-clhpp
    opencl-headers
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RELEASE"
  ];

  meta = with lib; {
    description = "glscopeclient and other client applications for libscopehal";
    homepage = "https://github.com/glscopeclient/scopehal-apps";
    license = licenses.bsd3;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.unix;
  };
}
