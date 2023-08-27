{ prev, final }:
{
  signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: {
    nativeBuildInputs = [
      final.nodejs_asar
    ] ++ oldAttrs.nativeBuildInputs;

    postInstall = ''
      asar extract $out/lib/Signal/resources/app.asar "$TMP/sigwork"
      substituteInPlace "$TMP/sigwork/stylesheets/manifest.css" \
        --replace "background-color: #121212;" "background-color: #000000;" \
        --replace "background-color: #2e2e2e;" "background-color: #000000;" \
        --replace "background-color: #3b3b3b;" "background-color: #000000;"
      asar pack "$TMP/sigwork" $out/lib/Signal/resources/app.asar
    '';
  });
}
