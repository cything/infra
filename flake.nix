{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-borg.url = "github:cything/nixpkgs/borg"; # unmerged PR
    nixpkgs-btrbk.url = "github:cything/nixpkgs/btrbk"; # unmerged PR
    eza.url = "github:nixos/nixpkgs/d722e8ce81cf103280ce1ff65accb3fc25cbd2ba";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.cything.io/central"
      "https://cache.cything.io/infra-ci"
      "https://cache.cything.io/attic"
    ];
    extra-trusted-public-keys = [
      "central:uWhjva6m6dhC2hqNisjn2hXGvdGBs19vPkA1dPEuwFg="
      "infra-ci:xG5f5tddUBcvToYjlpHD5OY/puYQkKmgKeIQCshNs38="
      "attic:HL3hVpqXxwcF7Q1R+IvU2i0+YxIjQA2xxKM5EJMXLLs="
    ];
    builders-use-substitutes = true;
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      treefmt,
      disko,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      inherit (self) outputs;

      systems = [ "x86_64-linux" ];
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});

      overridePkgsFromFlake =
        pkgs: flake: pkgNames:
        let
          pkgs' = import flake { inherit (pkgs) system config; };
          pkgNames' = builtins.map (lib.splitString ".") pkgNames;
          pkgVals = builtins.map (
            path:
            let
              package = lib.getAttrFromPath path pkgs';
            in
            lib.setAttrByPath path package
          ) pkgNames';
        in
        lib.foldl' lib.recursiveUpdate { } pkgVals;
      overlayPkgsFromFlake =
        flake: pkgNames: _final: prev:
        overridePkgsFromFlake prev flake pkgNames;
      overlays = [
        (overlayPkgsFromFlake inputs.eza [
          "eza"
        ])
      ] ++ import ./overlay;

      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system overlays;
          config = {
            allowUnfree = true;
          };
        }
      );

      treefmtEval = forEachSystem (
        pkgs:
        treefmt.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.stylua.enable = true;
          programs.yamlfmt.enable = true;
          programs.typos.enable = true;
          programs.shellcheck.enable = true;
          programs.deadnix.enable = true;

          settings.global.excludes = [ "secrets/*" ];
        }
      );
    in
    {
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = forEachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
      # lets us build overlaid packages with `nix build .#<package>`
      packages = pkgsFor;

      nixosConfigurations =
        let
          pkgs = pkgsFor.x86_64-linux;
        in
        {
          ytnix = lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              {
                nixpkgs = { inherit pkgs; };
              }
              ./hosts/ytnix
              inputs.sops-nix.nixosModules.sops
              ./modules
              inputs.lanzaboote.nixosModules.lanzaboote
            ];
          };

          chunk = lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              {
                nixpkgs = { inherit pkgs; };
              }
              ./hosts/chunk
              inputs.sops-nix.nixosModules.sops
              ./modules
            ];
          };

          titan = lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
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

      homeConfigurations = {
        "yt@ytnix" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./home/yt/ytnix.nix
            inputs.nixvim.homeManagerModules.nixvim
          ];
        };

        "yt@chunk" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./home/yt/chunk.nix
          ];
        };
      };
    };
}
