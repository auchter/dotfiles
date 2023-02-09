{ lib
, fetchFromGitea
, rustPlatform
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "listenbrainz-mpd";
  version = "2.0.2";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "elomatreb";
    repo = "listenbrainz-mpd";
    rev = "v${version}";
    sha256 = "sha256-DO7YUqaJZyVWjiAZ9WIVNTTvOU0qdsI2ct7aT/6O5dQ=";
  };

  cargoSha256 = "sha256-MiAalxe0drRHrST3maVvi8GM2y3d0z4Zl7R7Zx8VjEM=";

  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "ListenBrainz submission client for MPD written in Rust";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ auchter ];
  };
}
