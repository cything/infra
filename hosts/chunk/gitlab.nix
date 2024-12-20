{ config, ... }:
{
  services.gitlab = {
    enable = true;
    https = true;
    host = "git.cything.io";
    user = "git"; # so that you can ssh with git@git.cything.io
    group = "git";
    port = 443; # this *not* the port gitlab will run on
    puma.workers = 0; # https://docs.gitlab.com/omnibus/settings/memory_constrained_envs.html#optimize-puma
    sidekiq.concurrency = 10;
    databaseUsername = "git"; # needs to be same as user
    initialRootEmail = "hi@cything.io";
    initialRootPasswordFile = config.sops.secrets."gitlab/root".path;
    secrets = {
      secretFile = config.sops.secrets."gitlab/secret".path;
      otpFile = config.sops.secrets."gitlab/otp".path;
      jwsFile = config.sops.secrets."gitlab/jws".path;
      dbFile = config.sops.secrets."gitlab/db".path;
    };
  };
}