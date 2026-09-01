{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
  glibc,
}:

let
  version = "1.18.25";
  sources = {
    # NOTE: the prebuilt binaries are bun-compiled; patchelf corrupts the
    # embedded bundle, so on Linux the binary is kept untouched in libexec
    # and invoked through the glibc dynamic loader instead.
    x86_64-linux = {
      file = "opencode-linux-x64.tar.gz";
      hash = "sha256-WKNymm80Mt1tKRf8xKlJeIiRoDWBhkatSA4SyUf1bng=";
      loader = "ld-linux-x86-64.so.2";
    };
    aarch64-linux = {
      file = "opencode-linux-arm64.tar.gz";
      hash = "sha256-Ne93iXQl5BtRg6LCGsT7HU2UTYKpTjySD1e1SQrxGsU=";
      loader = "ld-linux-aarch64.so.1";
    };
    aarch64-darwin = {
      file = "opencode-darwin-arm64.zip";
      hash = "sha256-YGsJci2YBpYF4WA3+4w8fI67/tm6cTB5pe+y5bBlric=";
      loader = null;
    };
    x86_64-darwin = {
      file = "opencode-darwin-x64.zip";
      hash = "sha256-bFxWn3ebGX4d9jkMYieLvfDnPnzCSKQpZIaAxjpvPxw=";
      loader = null;
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "opencode: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "opencode";
  inherit version;

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/${source.file}";
    inherit (source) hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ makeWrapper ];

  installPhase =
    ''
      runHook preInstall
    ''
    + (
      if source.loader != null then
        ''
          install -Dm755 opencode $out/libexec/opencode
          makeWrapper ${glibc}/lib/${source.loader} $out/bin/opencode \
            --add-flags "$out/libexec/opencode"
        ''
      else
        ''
          install -Dm755 opencode $out/bin/opencode
        ''
    )
    + ''
      runHook postInstall
    '';

  meta = {
    description = "The open source AI coding agent, built for the terminal";
    homepage = "https://opencode.ai";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
