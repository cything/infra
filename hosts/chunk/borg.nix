{
  pkgs,
  config,
  ...
}:
{
  services.borgbackup.jobs = {
    crashRsync = {
      paths = [
        "/root"
        "/home"
        "/var/backup"
        "/var/lib"
        "/var/log"
        "/opt"
        "/etc"
        "/vw-data"
      ];
      exclude = [
        "**/.cache"
        "**/node_modules"
        "**/cache"
        "**/Cache"
        "/var/lib/docker"
        "/var/lib/containers/cache"
        "/var/lib/containers/overlay*"
      ];
      repo = "de3911@de3911.rsync.net:borg/crash";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg/rsyncnet".path}";
      };
      environment = {
        BORG_RSH = ''ssh -i ${config.sops.secrets."rsyncnet/id_ed25519".path}'';
        BORG_REMOTE_PATH = "borg1";
        BORG_EXIT_CODES = "modern";
      };
      compression = "auto,zstd,19";
      startAt = "hourly";
      extraCreateArgs = [
        "--stats"
        "-x"
      ];
      # warnings are often not that serious
      failOnWarnings = false;
      # anything other than exit code 1 is considered failure and BORG_EXIT_CODES=modern uses a whole lot more codes for warning
      appendFailedSuffix = false;
      postHook = ''
        ${pkgs.curl}/bin/curl -u $(cat ${
          config.sops.secrets."services/ntfy".path
        }) -d "chunk: backup completed with exit code: $exitStatus
        $(journalctl -u borgbackup-job-crashRsync.service|tail -n 5)" \
        https://ntfy.cything.io/chunk
      '';

      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
      extraPruneArgs = [ "--stats" ];
    };
  };
}
