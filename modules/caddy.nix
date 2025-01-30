{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.caddy;
in
{
  options.my.caddy = {
    enable = lib.mkEnableOption "caddy reverse proxy";
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          # error message will tell you the correct version tag to use
          # (still need the @ to pass nix config check)
          "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"
        ];
        hash = "sha256-jCcSzenewQiW897GFHF9WAcVkGaS/oUu63crJu7AyyQ=";
      };
      logFormat = lib.mkForce "level INFO";
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      extraConfig = ''
        (common) {
          encode zstd gzip
          header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
        }
      '';
      globalConfig = ''
        acme_dns cloudflare {$CLOUDFLARE_KEY}
      '';
      environmentFile = config.sops.secrets."caddy/env".path;
    };
  };
}
