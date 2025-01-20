{
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../foot.nix
    ../niri
    ../ghostty.nix
  ];
  home = {
    username = "yt";
    homeDirectory = "/home/yt";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern";
    };
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  home.sessionVariables = {
    ANKI_WAYLAND = "1";
    DISPLAY = ":0";
  };

  home.packages = with pkgs; [
    firefox
    ungoogled-chromium
    librewolf
    bitwarden-desktop
    bitwarden-cli
    fastfetch
    discord
    nwg-look
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.qtwayland
    mpv
    yt-dlp
    signal-desktop
    azure-cli
    pavucontrol
    btop
    grim
    slurp
    rofi-wayland
    rofimoji
    cliphist
    jq
    bash-language-server
    sqlite
    usbutils
    clang-tools
    calibre
    tor-browser
    wtype
    bat
    yarn
    rclone
    go
    rustup
    pwgen
    lua-language-server
    gnumake
    foot
    minisign
    unzip
    lm_sensors
    sshfs
    python312Packages.python-lsp-server
    gopls
    anki
    trezorctl
    trezor-agent
    q
    opentofu
    terraform-ls
    gdb
    clang
    seahorse
    github-cli
    fuzzel
  ];

  programs.waybar.enable = true;
  programs.feh.enable = true;

  services.mako = {
    enable = true;
    backgroundColor = "#1a1a1a";
    defaultTimeout = 5000;
    borderSize = 0;
    borderRadius = 10;
    font = "DejaVu Sans Mono 11";
    padding = "10";
    textColor = "#ffffff";
    extraConfig = ''
      [urgency=high]
      background-color=#c00000
      border-color=#ff0000
    '';
  };

  xdg.configFile = {
    rofi.source = ../rofi;
    waybar.source = ../waybar;
    mpv.source = ../mpv;
  };

  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "miniflux"
      miniflux-url "https://rss.cything.io/"
      miniflux-login "cy"
      miniflux-passwordfile /run/secrets/newsboat/miniflux
    '';
  };

  services.gnome-keyring.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
