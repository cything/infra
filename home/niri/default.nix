{
  config,
  pkgs,
  lib,
  ...
}:
let
  wallpaper = "${./nixos-c-book.png}";
  terminal = "ghostty";
  menu = [
    "fuzzel"
    "-w"
    "100"
  ];
  browser = "librewolf";
  file-manager = "thunar";
  clipboard = "cliphist list | ${lib.concatStringsSep " " menu} --dmenu | cliphist decode | wl-copy";
in
{
  programs.niri.settings = {
    prefer-no-csd = true;
    input.keyboard.xkb.options = "ctrl:nocaps";
    spawn-at-startup = [
      { command = [ "${lib.getExe pkgs.waybar}" ]; }
      {
        command = [
          "${lib.getExe pkgs.swaybg}"
          "-m"
          "fill"
          "-i"
          wallpaper
        ];
      }
      { command = [ "${lib.getExe pkgs.xwayland-satellite}" ]; }
    ];
    hotkey-overlay.skip-at-startup = true;

    input = {
      touchpad = {
        tap = true;
        dwt = true;
        natural-scroll = true;
        click-method = "clickfinger";
      };
      warp-mouse-to-focus = true;
      focus-follows-mouse.enable = false;
    };

    environment = {
      DISPLAY = ":0"; # for xwayland-satellite
    };

    layout = {
      gaps = 4;
      focus-ring = {
        width = 4;
        active.color = "#00000055";
        inactive.color = "#505050";
      };
      always-center-single-column = true;
      border.enable = false;
    };

    window-rules = [
      {
        matches = [
          {
            app-id = "anki";
            title = "Add";
          }
          { app-id = "mpv"; }
          { app-id = "Bitwarden"; }
        ];
        open-floating = true;
      }
      {
        matches = [ { app-id = "anki"; } ];
        default-column-width.proportion = .25;
      }
      {
        matches = [
          { app-id = "foot"; }
          {
            app-id = "anki";
            title = "^Browse";
          }
        ];
        default-column-width.proportion = .5;
      }
      {
        matches = [ { app-id = "librewolf"; } ];
        default-column-width.proportion = .75;
      }
    ];
  };

  programs.niri.settings.binds =
    with config.lib.niri.actions;
    let
      sh = spawn "sh" "-c";
    in
    {
      "Mod+Return".action = spawn terminal;
      "Mod+D".action = spawn menu;

      "Mod+Shift+E".action = quit;
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Super+Alt+L".action = spawn "swaylock";
      "Mod+Ctrl+Q".action = close-window;
      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;
      "Mod+K".action = focus-window-up;
      "Mod+J".action = focus-window-down;
      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+K".action = move-window-up;
      "Mod+Shift+J".action = move-window-down;
      "Mod+U".action = focus-workspace-up;
      "Mod+I".action = focus-workspace-down;
      "Mod+Shift+U".action = move-window-to-workspace-up;
      "Mod+Shift+I".action = move-window-to-workspace-down;
      "Mod+W".action = maximize-column;
      "Mod+C".action = center-column;
      "Mod+Shift+Space".action = toggle-window-floating;
      "Mod+Space".action = switch-focus-between-floating-and-tiling;
      "Print".action = screenshot;
      "Alt+Print".action = screenshot-window;
      "Ctrl+Print".action = screenshot-screen;
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-window-height;
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F".action = fullscreen-window;
      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action = focus-column-right;
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action = focus-column-left;
      };
      "Mod+Shift+WheelScrollDown" = {
        cooldown-ms = 150;
        action = focus-workspace-down;
      };
      "Mod+Shift+WheelScrollUp" = {
        cooldown-ms = 150;
        action = focus-workspace-up;
      };

      "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
      "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
      "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      "XF86MonBrightnessUp".action = sh "brightnessctl set 1%+";
      "XF86MonBrightnessDown".action = sh "brightnessctl set 1%-";

      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;
      "Mod+Shift+1".action = move-column-to-workspace 1;
      "Mod+Shift+2".action = move-column-to-workspace 2;
      "Mod+Shift+3".action = move-column-to-workspace 3;
      "Mod+Shift+4".action = move-column-to-workspace 4;
      "Mod+Shift+5".action = move-column-to-workspace 5;
      "Mod+Shift+6".action = move-column-to-workspace 6;
      "Mod+Shift+7".action = move-column-to-workspace 7;
      "Mod+Shift+8".action = move-column-to-workspace 8;
      "Mod+Shift+9".action = move-column-to-workspace 9;

      "Mod+Alt+B".action = spawn browser;
      "Mod+Alt+A".action = spawn "anki";
      "Mod+Alt+F".action = spawn file-manager;
      "Mod+Alt+E".action = spawn "evolution";
      "Mod+P".action = spawn "bitwarden";
      "Mod+Comma".action = sh clipboard;

      "MouseForward".action = spawn "sh" "${./scripts/remote.sh}" "btn1";
      "MouseBack".action = spawn "sh" "${./scripts/remote.sh}";
    };
}
