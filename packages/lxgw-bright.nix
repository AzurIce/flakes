{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "lxgw-bright";
  version = "5.526";

  src = fetchurl {
    url = "https://github.com/lxgw/LxgwBright/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-ybFPdSnx03ZDU7TbEcLdYhkSQhooxsvEDqOQ4VMygSM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    mv LXGWBright/*.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://lxgw.github.io/";
    description = "Open-source Chinese font derived from Fontworks' Klee One";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
