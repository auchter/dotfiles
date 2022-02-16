{ config, ... }:

{
  services.geoclue2 = {
    enable = true;
    appConfig = {
      "gammastep" = {
        isAllowed = true;
        isSystem = true;
        users = with config.users.users; map builtins.toString [
          a.uid
          guest.uid
        ];
      };
    };
  };

  location.provider = "geoclue2";
}
