{ prev, final }:
{
  cdrdao = prev.cdrdao.overrideAttrs (old: rec {
    version = "1.2.4";
    src = final.fetchurl {
      url = "mirror://sourceforge/cdrdao/cdrdao-${version}.tar.bz2";
      hash = "sha256-NY2cuDNwzq7NxgVky/FMLqJjbqxgqWbiRhwBG6CYU7Q=";
    };
  });
}

