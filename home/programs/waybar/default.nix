inputs@{ pkgs, system, mac, ... }:

{
  programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        position = "top";
        layer = "top";
        height = 30;
        spacing = 4;

        modules-left = [ "wlr/workspaces" "niri/workspaces" "temperature" "cpu" "memory" "mpd" ];
        modules-center = [ "wlr/window" "niri/window" ];
        modules-right = [
          "pulseaudio"
          "backlight"
          "network"
          "battery"
          "clock"
          "tray"
        ];


        "niri/workspaces" = {
          format = "{value}";
        };

        "wlr/workspaces" = {
          format = "{name}";
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace e-1";
          on-scroll-down = "hyprctl dispatch workspace e+1";
          sort-by-number = true;
        };

        temperature = {
          critical-threshold = 80;
        };

        clock = {
          interval = 60;
          align = 0;
          rotate = 0;
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          format = " {:%H:%M}";
          format-alt = " {:%a %b %d, %G}";
        };


        cpu = {
            format = "{usage}% ";
            tooltip = false;
        };
        memory = {
            format = "{}% ";
        };

        network = {
            # "interface": "wlp2*", // (Optional) To force the use of this interface
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr}";
            format-linked = "{ifname} (No IP)";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
      };
    };
  };
}
