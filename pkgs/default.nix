{ pkgs ? null }:
{
  brutefir = pkgs.callPackage ./brutefir { };
  drduh-yubikey-guide = pkgs.callPackage ./drduh-yubikey-guide { };
  dterm = pkgs.callPackage ./dterm { };
}
