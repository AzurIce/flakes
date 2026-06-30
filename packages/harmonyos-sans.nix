{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "harmonyos-sans";
  version = "1.0";

  src = fetchurl {
    name = "HarmonyOS_Sans.zip";
    url = "https://media.githubusercontent.com/media/huawei-fonts/HarmonyOS-Sans/main/HarmonyOS%20Sans.zip";
    sha256 = "0gkdfah5g013sz0cw6fwiic822mpqwcia8d71pb4hs6hraw6hvl0";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    find . -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} $out/share/fonts/truetype/ \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "HarmonyOS Sans font by Huawei";
    homepage = "https://github.com/huawei-fonts/HarmonyOS-Sans";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}

