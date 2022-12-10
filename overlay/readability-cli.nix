{ prev, final }:
{
 nodePackages.readability-cli = prev.nodePackages.readability-cli.override (oldAttrs: {
    # Wrap src to fix this build error:
    # > readability-cli/readable.ts: unsupported interpreter directive "#!/usr/bin/env -S deno..."
    #
    # Need to wrap the source, instead of patching in patchPhase, because
    # buildNodePackage only unpacks sources in the installPhase.
    src = final.srcOnly {
      src = oldAttrs.src;
      name = oldAttrs.name;
      patchPhase = "chmod a-x readable.ts";
    };

    nativeBuildInputs = [ final.pkg-config ];
    buildInputs = with final; [
      pixman
      cairo
      pango
    ];
  });
}
