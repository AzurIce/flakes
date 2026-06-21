{ ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # blueman-applet and blueman-manager
  services.blueman.enable = true;
}
