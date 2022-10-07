{ prev, final }:
{
  snapcast = prev.snapcast.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./0001-Hack-in-BruteFIR-support.patch
      ./0002-Add-brutefir_config-option.patch
      ./0003-include-missing-headers.patch
    ];
    postPatch = ''
      substituteInPlace client/brutefir.cpp --replace \
        'bp::search_path("brutefir");' 'boost::filesystem::path("${final.brutefir}/bin/brutefir");'
    '';
  });
}
