{ lib
, stdenv
, fetchFromGitLab
, python3Packages
, meson
, gettext
, pkg-config
, glib
, gtk3
, desktop-file-utils
, ninja
, wrapGAppsHook
, gobject-introspection
, gnome-icon-theme
}:

python3Packages.buildPythonApplication rec {
  pname = "mcg";
  version = "3.2.1";

  src = fetchFromGitLab {
    owner = "coderkun";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-awPMXGruCB/2nwfDqYlc0Uu9E6VV1AleEZAw9Xdsbt8=";
  };

  buildInputs = [
    gettext
    glib
    gtk3
  ];

  nativeBuildInputs = [
    wrapGAppsHook
    gobject-introspection
    meson
    ninja
    pkg-config
    desktop-file-utils
  ];

  format = "other";
  propagatedBuildInputs = with python3Packages; [
    gnome-icon-theme
    python-dateutil
    pygobject3
    setuptools
    gobject-introspection
    gtk3
  ];

  meta = with lib; {
    homepage = "https://www.suruatoel.xyz/codes/mcg";
    description = "MPD client focusing on albums instead of single tracks";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}
