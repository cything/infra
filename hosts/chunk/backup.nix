{
  config,
  ...
}:
{
  my.backup = {
    enable = true;
    jobName = "crashRsync";
    paths = [
      "/vw-data"
    ];
    repo = "crash";
    passFile = config.sops.secrets."borg/rsyncnet".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };
}