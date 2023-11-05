{ lib
, writeShellApplication
, khal
}:

writeShellApplication {
  name = "cal-add";
  runtimeInputs = [ khal ];
  text = ''
    set -e
    ICS="$1"

    if grep 'UID:-https://www.austinshowspot.com/' "$ICS"; then
            # times are local, but incorrectly specified as UTC
            # Add TZID; khal will emit a warning but do the right thing...
            sed -i 's#DTSTART:#DTSTART;TZID=America/Chicago:#' "$ICS"
            sed -i 's#DTEND:#DTEND;TZID=America/Chicago:#' "$ICS"
    fi

    ${khal}/bin/khal import --batch -r "$ICS"
    rm "$ICS"
  '';
}
