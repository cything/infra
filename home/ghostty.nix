{ ... }: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "IBM Plex Mono";
      font-size = 8;
      window-decoration = false;
    };
  };
}
