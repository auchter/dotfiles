{ lib
, stdenv
, fetchFromGitHub
, mkYarnPackage
, fetchYarnDeps
, fixup_yarn_lock
}:

mkYarnPackage rec {
  pname = "photostructure";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "photostructure";
    repo = "photostructure-for-servers";
    rev = "v${version}";
    sha256 = "sha256-cQXTWOw+qm1e5Zj62UtSkzSY7WxLDUBJYZOKWEC6oM8=";
  };

  packageJSON = ./package.json;
  yarnOfflineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    sha256 = "sha256-EcGaog8wY3WNISX++2Q03xwAUX5F9QGLzxee2qbc/v0=";
  };

  nativeBuildInputs = [ fixup_yarn_lock ];

  configurePhase = ''
    cp -rL $node_modules node_modules
    chmod -R +w node_modules
    mkdir deps
  '';

  buildPhase = ''
    runHook preBuild

    export HOME=$PWD
    ls -lsa /build
    ls -lsa /build/source
    yarn config --offline set yarn-offline-mirror ${yarnOfflineCache}
    fixup_yarn_lock ~/yarn.lock
    yarn --offline --skip-integrity-check --frozen-lockfile --ignore-engines --ignore-scripts install

    runHook postBuild
  '';

}
