{ ... }:
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      flake-registry = "";
      trusted-users = [
        "root"
        "@wheel"
      ];
      trusted-public-keys = [ "central:uWhjva6m6dhC2hqNisjn2hXGvdGBs19vPkA1dPEuwFg=" ];
      substituters = [ "https://cache.cything.io/central" ];
    };
    channel.enable = false;
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    gc = {
      automatic = true;
      dates = "19:00";
      persistent = true;
      options = "--delete-older-than 14d";
    };
    extraOptions = ''
      	    builders-use-substitutes = true
      	  '';
  };
  time.timeZone = "America/Toronto";
  networking.firewall.logRefusedConnections = false;
  networking.nameservers = [
    # quad9
    "2620:fe::fe"
    "2620:fe::9"
    "9.9.9.9"
    "149.112.112.112"
  ];

  # this is true by default and mutually exclusive with
  # programs.nix-index
  programs.command-not-found.enable = false;
  programs.nix-index.enable = false; # set above to false to use this

  # see journald.conf(5)
  services.journald.extraConfig = "MaxRetentionSec=2d";
}
