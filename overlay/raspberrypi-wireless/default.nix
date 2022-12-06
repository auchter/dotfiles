{ prev, final }:
{
  raspberrypiWirelessFirmware = prev.raspberrypiWirelessFirmware.overrideAttrs (old: {
    installPhase = old.installPhase + ''
      pushd $out/lib/firmware/brcm &>/dev/null
      ln -s "./brcmfmac43436-sdio.bin" "$out/lib/firmware/brcm/brcmfmac43430b0-sdio.raspberrypi,model-zero-2-w.bin"
      ln -s "./brcmfmac43436-sdio.txt" "$out/lib/firmware/brcm/brcmfmac43430b0-sdio.raspberrypi,model-zero-2-w.txt"
      popd &>/dev/null
    '';
  });
}
