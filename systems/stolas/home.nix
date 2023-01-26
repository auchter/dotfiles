{
  modules.beets = {
    enable = true;
    musicDir = "/mnt/storage/music";
    smartPlaylists = let
      albumQuery = x: { album_query = x; };
      itemQuery = x : { query = x; };
    in {
      "%left{$added, 7} - New Albums" = albumQuery "added:2022-11.. added-";
      "Aphex Twin - Analord" = itemQuery "album:Analord album+";
      "Autechre - Elseq" = albumQuery "albumartist:Autechre album:elseq";
      "Autechre - NTS Sessions" = albumQuery "albumartist:Autechre album:'NTS Session'";
      "Frank Zappa - Joe's Garage" = albumQuery "albumartist:'Frank Zappa' album:Garage";
      "Frank Zappa - 1973-12-09 Show 1, Roxy Performances" = itemQuery "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐9‐73 show 1'";
      "Frank Zappa - 1973-12-09 Show 2, Roxy Performances" = itemQuery "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐9‐73 show 2'";
      "Frank Zappa - 1973-12-10 Show 1, Roxy Performances" = itemQuery "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐10‐73 show 1'";
      "Frank Zappa - 1973-12-10 Show 2, Roxy Performances" = itemQuery "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐10‐73 show 2'";
      "John Zorn - Book of Angels" = albumQuery "album:'Book of Angels' year+ month+ day+";
      "John Zorn - Gnostic Trio" = albumQuery "album:netzach, album:mockingbird";
      "John Zorn - Moonchild" = albumQuery "album:astronome, album:moonchild, album:'six litanies', album:'the crucible'";
      "John Zorn - Simulacrum" = albumQuery "album:Simulacrum, album:'true discoveries of witches', album:'baphomet', album:'garden of earthly delights'";
      "John Zorn - The Book Beri'ah" = albumQuery "album:'The Book Beri' year+ month+ day+";
      "Secret Chiefs 3 - Singles" = albumQuery "albumartist:'Secret Chiefs 3' albumtype:single";
    };
  };
}
