{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide
      editorconfig.editorconfig
      github.github-vscode-theme
      github.codespaces
    ];
    userSettings = {
      "workbench.colorTheme" = "GitHub Dark Default";
      "files.autoSave" = "afterDelay";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "editor.fontFamily" = "IBM Plex Mono";
      "editor.fontSize" = 16;
      "editor.wordWrap" = "on";

      # vim mode settings
      "vim.handleKeys" = {
        "<C-b>" = false; # file tree toggle
      };
      "vim.normalModeKeyBindings" = [
        {
          "before" = [ ";" ];
          "after" = [ ":" ];
          "silent" = true;
        }
      ];
      "workbench.startupEditor" = "none";
    };
  };
}
