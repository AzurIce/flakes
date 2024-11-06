inputs@{ pkgs, mac, ... }:

{
  home.packages = with pkgs; [
    eww
    jq
    socat

    kitty
    rofi-wayland
    wlogout
    hyprpaper
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${./imgs/Amiya.jpeg}"
      ];
      wallpaper = [
        ",${./imgs/Amiya.jpeg}"
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    settings = {
      input = {
        touchpad.natural_scroll = true;
        sensitivity = 0.5;
        accel_profile = "adaptive";
      };
      monitor = [
        "desc:Philips Consumer Electronics Company PHL 345M1CR UK02107000363, 3440x1440@144, auto, 1.0"
        ", preferred, auto, 1"
      ];
      general = {
        gaps_in = 3;
        gaps_out = 5;
        border_size = 3;
        "col.active_border" = "rgba(50bbddee)";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
      };
      decoration = {
        rounding = 3;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          ignore_window = true;
          color = "rgba(1a1a1aee)";
        };
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = false;
      };
      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 250;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 15;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = false;
      };
      misc = {
        disable_hyprland_logo = true;
        always_follow_on_dnd = true;
        layers_hog_keyboard_focus = true;
        animate_manual_resizes = false;
        enable_swallow = true;
        focus_on_activate = true;
      };
      cursor = {
        enable_hyprcursor = false;
      };
      bind =
        (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        ) ++ [
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
        ] ++ [
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ] ++ [
          "$alt, Space, exec, rofi -show drun"
          "$mod, Return, exec, kitty"
          "$mod, Escape, exec, wlogout"
          "$mod, E, exec, nautilus"
          "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
        ];
      bindm =
        [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      exec-once = [
        "eww open topbar & hyprpaper & fcitx5 & clash-verge & syncthingtray --wait"
      ];
      windowrulev2 = [
        "float, class:org.fcitx."
        "float, class:clash-verge"
      ];
    } // {
      "$mod" = if mac then
        "ALT"
      else
        "SUPER";

      "$alt" = if mac then
        "SUPER"
      else
        "ALT";
    };
  };

  # home.file.".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
  # home.file.".config/hypr/hyprpaper.conf".source = ./hypr/hyprpaper.conf;

  # Note: the sessionVariables will be only set when home-manager manager a shell
  # e.g. fish, bash
  home.sessionVariables = {
    # EDITOR = "nvim";
    # BROWSER = "firefox";
    # TERMINAL = "kitty";

    # QT_QPA_PLATFORMTHEME = "gtk3";
    # QT_SCALE_FACTOR = "1";
    # MOZ_ENABLE_WAYLAND = "1";
    # SDL_VIDEODRIVER = "wayland";
    # _JAVA_AWT_WM_NONREPARENTING = "1";
    # QT_QPA_PLATFORM = "wayland";
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";

    # # Hyprland launch
    # LIBVA_DRIVER_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1";

    # # Force using GBM backend
    # # But With GBM_BACKEND = "nvidia-drm", firefox will crash.
    # # Obsidian will randomly freezes the entire system with hardware acceleration on,
    # # it has no thing to do with this line but some problem of the intel driver,
    # # See https://forum.obsidian.md/t/obsidian-randomly-freezes-the-entire-system/45683
    # # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # #CLUTTER_BACKEND = "wayland";

    # #vulkan
    # WLR_RENDERER = "vulkan";
    # #__NV_PRIME_RENDER_OFFLOAD="1";

    # XDG_CURRENT_DESKTOP = "Hyprland";
    # XDG_SESSION_DESKTOP = "Hyprland";
    # XDG_SESSION_TYPE = "wayland";
    # XDG_CACHE_HOME = "\${HOME}/.cache";
    # XDG_CONFIG_HOME = "\${HOME}/.config";
    # XDG_BIN_HOME = "\${HOME}/.local/bin";
    # XDG_DATA_HOME = "\${HOME}/.local/share";
  };
}
