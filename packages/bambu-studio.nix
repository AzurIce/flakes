{
  bambu-studio,
  fetchPnpmDeps,
  nodejs_22,
  pnpm_10,
  pnpmConfigHook,
  stdenvNoCC,
}:

let
  base = bambu-studio.override { withNvidiaGLWorkaround = true; };

  # nixpkgs disables upstream's network-dependent CMake frontend build.
  # Build the matching frontend separately with locked, offline dependencies.
  devicePage = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "bambu-studio-device-page";
    inherit (base) version src;
    sourceRoot = "${finalAttrs.src.name}/src/slic3r/GUI/DeviceWeb/device_page";

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname src sourceRoot;
      pnpm = pnpm_10;
      fetcherVersion = 5;
      hash = "sha256-zV88mxayrMvkfa7eGXEaCWlRvhsbfWyQXVN3CZXddhI=";
    };

    nativeBuildInputs = [
      nodejs_22
      pnpm_10
      pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r dist/. "$out/"
      test -s "$out/index.html"
      runHook postInstall
    '';
  });
in
base.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    mkdir -p "$out/share/BambuStudio/web/device_page/dist"
    cp -r ${devicePage}/. "$out/share/BambuStudio/web/device_page/dist/"
    test -s "$out/share/BambuStudio/web/device_page/dist/index.html"
  '';

  passthru = (old.passthru or { }) // {
    inherit devicePage;
  };
})
