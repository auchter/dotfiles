{ ... }:

{
  services.smartd = {
    enable = true;
    notifications = {
      mail = {
        enable = true;
        sender = "nix@phire.org";
        recipient = "a@phire.org";
      };
    };
  };
}
