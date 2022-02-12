{ config, ... }:

{
  services.geoclue2 = {
    enable = true;
    appConfig = {
      "gammastep" = {
        isAllowed = true;
        isSystem = true;
        users = [ "1000" ];
      };
    };
  };

  location.provider = "geoclue2";
}
