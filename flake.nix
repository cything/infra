{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-garage.url = "github:cything/nixpkgs/garage-module"; # unmerged PR
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.cything.io/central"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "central:uWhjva6m6dhC2hqNisjn2hXGvdGBs19vPkA1dPEuwFg="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    builders-use-substitutes = true;
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          inputs.treefmt.flakeModule
        ];
        debug = true;
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            system,
            ...
          }:
          {
            # make pkgs available to `perSystem`
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
            };

            treefmt = {
              projectRootFile = "flake.nix";
              programs.nixfmt.enable = true;
              programs.stylua.enable = true;
              programs.yamlfmt.enable = true;
              programs.typos.enable = true;
              programs.shellcheck.enable = true;

              settings.global.excludes = [
                "secrets/*"
                "**/*.png" # tries to format a png file??
              ];
            };
          };

        flake =
          let
            pkgs = import nixpkgs {
              config.allowUnfree = true;
              system = "x86_64-linux";
              overlays = [ inputs.niri.overlays.niri ] ++ import ./overlay;
            };
          in
          {
            nixosConfigurations =
              let
                lib = nixpkgs.lib;
              in
              {
                ytnix = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs = { inherit pkgs; };
                    }
                    ./hosts/ytnix
                    inputs.sops-nix.nixosModules.sops
                    ./modules
                    inputs.lanzaboote.nixosModules.lanzaboote
                    inputs.niri.nixosModules.niri
                  ];
                };
                chunk = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs = { inherit pkgs; };
                      disabledModules = [
                        "services/web-servers/garage.nix"
                      ];
                    }
                    ./hosts/chunk
                    inputs.sops-nix.nixosModules.sops
                    ./modules
                    (inputs.nixpkgs-garage + "/nixos/modules/services/web-servers/garage.nix")
                  ];
                };

                titan = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs = { inherit pkgs; };
                    }
                    ./hosts/titan
                    disko.nixosModules.disko
                    inputs.sops-nix.nixosModules.sops
                    ./modules
                  ];
                };
              };
            homeConfigurations =
              let
                lib = home-manager.lib;
              in
              {
                "yt@ytnix" = lib.homeManagerConfiguration {
                  inherit pkgs;
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/ytnix.nix
                    inputs.nixvim.homeManagerModules.nixvim
                    inputs.niri.homeModules.config
                  ];
                };

                "yt@chunk" = lib.homeManagerConfiguration {
                  inherit pkgs;
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/chunk.nix
                    inputs.nixvim.homeManagerModules.nixvim
                  ];
                };

                "codespace@codespace" = lib.homeManagerConfiguration {
                  inherit pkgs;
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/codespace.nix
                    inputs.nixvim.homeManagerModules.nixvim
                  ];
                };
              };
          };
      }
    );
}
