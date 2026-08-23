{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
  glibc,
}:

let
  version = "1.18.21";
  sources = {
    # NOTE: the prebuilt binaries are bun-compiled; patchelf corrupts the
    # embedded bundle, so on Linux the binary is kept untouched in libexec
    # and invoked through the glibc dynamic loader instead.
    x86_64-linux = {
      file = "opencode-linux-x64.tar.gz";
      hash = "sha256-2RDD7XYTu1eRoyiQRhXUHMJbfTprRw4xmasEJqmVs4o=";
      loader = "ld-linux-x86-64.so.2";
    };
    aarch64-linux = {
      file = "opencode-linux-arm64.tar.gz";
      hash = "sha256-0w0sunRhf057luJVY8lXL/5FP56ucPwN8WKGgTU37nI=";
      loader = "ld-linux-aarch64.so.1";
    };
    aarch64-darwin = {
      file = "opencode-darwin-arm64.zip";
      hash = "sha256-cvS2AprxhesDCZXPoGLQOJFOMULJqjj3FP5WRI5uh9I=";
      loader = null;
    };
    x86_64-darwin = {
      file = "opencode-darwin-x64.zip";
      hash = "sha256-QFVZ5Yc6kTH/a8r8QT9G1PGZtEAfIy0AvNMB2X6nzfw=";
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
