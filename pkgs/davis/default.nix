{ lib
, fetchFromGitHub
, rustPlatform
, rust-bin
, gawk
, gnugrep
, fzf
}:

rustPlatform.buildRustPackage rec {
  pname = "davis";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "SimonPersson";
    repo = pname;
    rev = version;
    sha256 = "sha256-Xw4X9n0PCuigZhBA6so8pVI26pLRGeGjtR0l7uHw1vA=";
  };

  cargoSha256 = "sha256-gpxcJbl2FrWjsPUi/BBZ/uyoVxmbBlXT7KYbESpI1+I=";

  doCheck = false;

  nativeBuildInputs = [
    rust-bin.stable.latest.default
  ];

  postInstall = ''
    cp subcommands/fzf/davis-fzf $out/bin
    chmod +x $out/bin/davis-fzf
    substituteInPlace $out/bin/davis-fzf \
      --replace 'fzf' '${fzf}/bin/fzf' \
      --replace 'grep' '${gnugrep}/bin/grep' \
      --replace 'awk' '${gawk}/bin/awk'
  '';

  meta = with lib; {
    description = "A CLI client for MPD";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ auchter ];
  };
}
