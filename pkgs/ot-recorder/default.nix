{ lib
, stdenv
, fetchFromGitHub
, curl
, libconfig
, libsodium
, libuuid
, lmdb
, lua
, mosquitto
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "ot-recorder";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "owntracks";
    repo = "recorder";
    rev = "c6bfa2827c03372740bf1bede9ad80cc9d5aa395";
    sha256 = "sha256-/y74jfofvWTcHSX+9wtrCRclaS5Aw03TCz11mrZiqiM=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    libconfig
    libsodium
    libuuid
    lmdb
    lua
    mosquitto
  ];

  configurePhase = ''
    runHook preConfigure

    cp config.mk.in config.mk
    cat <<END >>config.mk
    WITH_LUA=yes
    DOCROOT=$out/share/htdocs
    CONFIGFILE=$out/etc/default/ot-recorder
    END

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/sbin
    install -m 0755 ot-recorder $out/sbin
    install -m 0755 ocat $out/bin

    mkdir -p $out/share/htdocs
    cp -R docroot/* $out/share/htdocs

    mkdir -p $out/etc/default
    install -m 640 etc/ot-recorder.default $out/etc/default/ot-recorder

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/owntracks/recorder";
    description = "Store and access data published by OwnTracks apps";
    license = licenses.gpl2;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
