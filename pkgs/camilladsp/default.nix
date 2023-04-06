{ lib
, fetchFromGitHub
, rustPlatform
, rust-bin
, pkg-config
, openssl
, alsa-lib
}:

rustPlatform.buildRustPackage rec {
  pname = "camilladsp";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "HEnquist";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-uNtmE4EYaEtbaa4R9B90nHBz8vNQARdfM1jPbZGuE3s=";
  };

  cargoPatches = [
    ./0001-add-cargo-lock.patch
  ];

  cargoSha256 = "sha256-M2p+7M/52lUT9JJVTGJBy34g3vmyQbmsOcpTkFBe4Yw=";

  nativeBuildInputs = [
    pkg-config
    rust-bin.stable.latest.default
  ];

  buildInputs = [
    openssl
    alsa-lib
  ];

  meta = with lib; {
    description = " A flexible cross-platform IIR and FIR engine for crossovers, room correction etc.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ auchter ];
  };
}
