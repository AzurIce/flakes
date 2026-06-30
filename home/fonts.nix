inputs@{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "HarmonyOS Sans" ];
      serif = [ "HarmonyOS Sans" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };

  xdg.configFile."fontconfig/conf.d/99-harmonyos-aliases.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <match target="pattern">
        <test name="family" qual="any"><string>Arial</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>Helvetica</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>Segoe UI</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>Microsoft YaHei</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>PingFang SC</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>-apple-system</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>BlinkMacSystemFont</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>SimSun</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>宋体</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
      <match target="pattern">
        <test name="family" qual="any"><string>黑体</string></test>
        <edit name="family" mode="assign" binding="strong"><string>HarmonyOS Sans</string></edit>
      </match>
    </fontconfig>
  '';

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ] ++ [
    (pkgs.callPackage ../packages/lxgw-bright.nix {})
    (pkgs.callPackage ../packages/harmonyos-sans.nix {})
  ];
}
