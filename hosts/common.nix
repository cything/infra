{ inputs, ... }:
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
      trusted-public-keys = [
        "central:uWhjva6m6dhC2hqNisjn2hXGvdGBs19vPkA1dPEuwFg="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cything.cachix.org-1:xqW1W5NNL+wrM9wfSELb0MLj/harD2ZyB4HbdaMyvPI="
      ];
      substituters = [
        "https://aseipp-nix-cache.global.ssl.fastly.net"
        "https://cache.cything.io/central"
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://cything.cachix.org"
      ];
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
    registry.nixpkgs.flake = inputs.nixpkgs;
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
