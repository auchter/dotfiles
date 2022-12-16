{ prev, final }:
{
  mopidy-subidy = prev.mopidy-subidy.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "auchter";
      repo = old.pname;
      rev = "dae5ab1e5a35dd3805a67bcc66185c1e24526570";
      sha256 = "sha256-RTwHtFx2vKtexsJqg8nmKICun+bBeWwBrNV+6PCMRsk=";
    };
  });
}
