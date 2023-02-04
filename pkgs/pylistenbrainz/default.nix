{ lib
, fetchFromGitHub
, python3Packages
, git
}:

python3Packages.buildPythonApplication rec {
  pname = "pylistenbrainz";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "metabrainz";
    repo = pname;
    rev = "v${version}";
    leaveDotGit = true;
    sha256 = "sha256-U2mpBtAsRXzYAz0wi4BrAAvm7xElB8oLvbev9pnd0KQ=";
  };

  nativeBuildInputs = [
    git
  ];

  propagatedBuildInputs = with python3Packages; [
    requests
    setuptools_scm
  ];

  # tries to connect to the listenbrainz in the test...
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/metabrainz/pylistenbrainz";
    description = "A simple ListenBrainz client library for Python";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}

