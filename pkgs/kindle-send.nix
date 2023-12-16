{ lib
, writeShellApplication
, pandoc
, neomutt
, readability-cli
, curl
}:

writeShellApplication {
  name = "kindle-send";
  runtimeInputs = [
    curl
    neomutt
    readability-cli
    pandoc
  ];

  text = ''
    set -e

    process_url () {
      local tmpdir
      tmpdir=$(mktemp -d)
      local html=$tmpdir/site.html

      curl "$1" -o "$html"
      local title
      title=$(readable -p title "$html" )
      readable "$html" | pandoc -f html -t epub --metadata title:"$title" > "$tmpdir/$title.epub"
      echo "$tmpdir/$title.epub"
    }

    send2kindle () {
      echo | neomutt -s convert -a "$1" -- michael.auchter@kindle.com
    }

    for arg in "$@"; do
      if [[ -f "$arg" ]]; then
        send2kindle "$arg"
      else
        file=$(process_url "$arg")
        send2kindle "$file"
      fi
    done
  '';
}
