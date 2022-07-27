{ lib
, stdenv
, fetchFromGitHub
, pandoc
}:

stdenv.mkDerivation {
  name = "drduh-yubikey-guide";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "drduh";
    repo = "YubiKey-Guide";
    rev = "dc29279197bbf866b63976395d2c69b1a95ad088";
    sha256 = "sha256-MMcfiJ31SsrJdPCYn+5MuUxqLJzhY4VeqOS02T9AlL8=";
  };

  nativeBuildInputs = [ pandoc ];

  buildPhase = ''
    pandoc --standalone --to man README.md > yubikey-guide.7
    pandoc --standalone --to html README.md > yubikey-guide.html
  '';

  installPhase = ''
    mkdir -p $out/share
    cp README.md $out/share
    cp yubikey-guide.html $out/share
  '';

  postInstall = ''
    installManPage yubikey-guide.7
  '';

  meta = with lib; {
    description = "Guide to using YubiKey for GPG and SSH";
    homepage = "https://github.com/drduh/YubiKey-Guide";
    license = licenses.mit;
    platform = platforms.all;
  };
}
