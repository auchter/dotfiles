{ config, pkgs, lib, ... }:

let
  sites = {
    hn = "https://news.ycombinator.com";
    liveoak = "https://liveoakbrewing.com/taproom/";
    pinthouse = "https://pinthouse.com/burnet/beer/beer-on-tap";
    zilker = "https://zilkerbeer.com/?v=47e5dceea252#seasonals-beer";
    spicyboys = "https://spicyboyschicken.square.site/?location=11eb52928bec852a8648ac1f6bbbd01e";
    cuantos = "https://www.cuantostacosaustin.com/s/order";
    betterhalf = "https://www.betterhalfbar.com/menu";
    dh = "https://www.draughthouse.com/drinks";
    workhorse = "https://workhorsebar.e-tab.com/workhorsebar/venue/5ea0812fad8074513197d76a/menu";
    chinafamily = "https://chinafamilytx.com/menu/64123353";
    holdout = "https://holdoutbrewing.com/menus";
    tlocs = "https://tlocs-hotdogs-103892-107872.square.site/";
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
