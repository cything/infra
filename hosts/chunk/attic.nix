{ config, ... }:
{
  services.atticd = {
    enable = true;

    environmentFile = config.sops.secrets."attic/env".path;

    settings = {
      listen = "[::]:8090";
      api-endpoint = "https://cache.cything.io/";
      allowed-hosts = [ "cache.cything.io" ];
      require-proof-of-possession = false;
      compression.type = "zstd";
      database.url = "postgresql:///atticd?host=/run/postgresql";

      storage = {
        type = "local";
        path = "/mnt/attic";
      };

      garbage-collection = {
        default-retention-period = "1 minute";
      };

      chunking = {
        nar-size-threshold = 0; # disables chunking
        min-size = 0;
        avg-size = 0;
        max-size = 0;
      };
    };
  };
}
