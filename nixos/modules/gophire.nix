{ config, pkgs, lib, ... }:

let
  sites = {
    "hn" = "https://news.ycombinator.com";
    "lo" = "https://liveoakbrewing.com/taproom/";
    "ph" = "https://pinthouse.com/burnet/beer/beer-on-tap";
    "zb" = "https://zilkerbeer.com/?v=47e5dceea252#seasonals-beer";
    "sb" = "https://spicyboyschicken.square.site/?location=11eb52928bec852a8648ac1f6bbbd01e";
    "ct" = "https://www.cuantostacosaustin.com/s/order";
    "bh" = "https://www.betterhalfbar.com/menu";
    "dh" = "https://www.draughthouse.com/drinks";
    "wh" = "https://workhorsebar.e-tab.com/workhorsebar/venue/5ea0812fad8074513197d76a/menu";
    "cf" = "https://chinafamilytx.com/menu/64123353";
  };
in
{
  environment.etc."gophire/index.html".text = ''
    <html>
      <head><title>go shortcodes</title></head>
      <body><ul>
  '' +
  builtins.foldl' (x: y: x + y) "" (
    builtins.attrValues (
      lib.mapAttrs (short: url: "<li>${short} = <a href=\"${url}\">${url}</a></li>") sites )) +
  ''
      </ul></body>
    </html>
  '';

  services.nginx = {
    enable = true;
    virtualHosts = {
      "go.phire.org" = {
        enableACME = true;
        forceSSL = true;
        locations = lib.mapAttrs' (short: url: lib.nameValuePair ("/" + short) { return = "301 ${url}"; }) sites
          // { "/" = { root = "/etc/gophire"; }; };
      };
    };
  };
}
