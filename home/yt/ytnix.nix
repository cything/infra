{
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../foot.nix
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
  };

  programs.git = {
    enable = true;
    userName = "cy";
    userEmail = "hi@cything.io";
    delta.enable = true;
  };

  programs.neovim.enable = true;

  home.packages = with pkgs; [
    firefox
    ungoogled-chromium
    librewolf
    bitwarden-desktop
    bitwarden-cli
    aerc
    fastfetch
    discord
    nwg-look
    element-desktop-wayland
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
    llvmPackages_19.clang-tools
    calibre
    tor-browser
    wtype
    bat
    yarn
    rclone
    go
    rustup
    clang_19
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
    sway.source = ../sway;
    rofi.source = ../rofi;
    waybar.source = ../waybar;
  };
}
