{ prev, final }:
{
  raspberrypiWirelessFirmware = prev.raspberrypiWirelessFirmware.overrideAttrs (old: {
    # From https://build.opensuse.org/package/view_file/openSUSE:Factory/bcm43xx-firmware/bcm43xx-firmware.spec?expand=1
    installPhase = old.installPhase + ''
      pushd $out/lib/firmware/brcm &>/dev/null
      ln -s "./brcmfmac43436-sdio.bin" "$out/lib/firmware/brcm/brcmfmac43430b0-sdio.raspberrypi,model-zero-2-w.bin"
      ln -s "./brcmfmac43436-sdio.txt" "$out/lib/firmware/brcm/brcmfmac43430b0-sdio.raspberrypi,model-zero-2-w.txt"
      ln -s "./brcmfmac43436-sdio.clm_blob" "$out/lib/firmware/brcm/brcmfmac43430b0-sdio.clm_blob"
      popd &>/dev/null
    '';
  });
}
