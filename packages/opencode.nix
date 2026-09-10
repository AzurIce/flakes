{
  lib,
  stdenvNoCC,
  unzip,
  makeWrapper,
  glibc,
  sources,
}:

let
  version = sources.opencode-x86_64-linux.version;
  src = {
    x86_64-linux = sources.opencode-x86_64-linux.src;
    aarch64-linux = sources.opencode-aarch64-linux.src;
    x86_64-darwin = sources.opencode-x86_64-darwin.src;
    aarch64-darwin = sources.opencode-aarch64-darwin.src;
  }.${stdenvNoCC.hostPlatform.system}
    or (throw "opencode: unsupported system ${stdenvNoCC.hostPlatform.system}");
  # NOTE: the prebuilt binaries are bun-compiled; patchelf corrupts the
  # embedded bundle, so on Linux the binary is kept untouched in libexec
  # and invoked through the glibc dynamic loader instead.
  loader = {
    x86_64-linux = "ld-linux-x86-64.so.2";
    aarch64-linux = "ld-linux-aarch64.so.1";
    aarch64-darwin = null;
    x86_64-darwin = null;
  }.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "opencode";
  inherit version src;

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ makeWrapper ];

  installPhase =
    ''
      runHook preInstall
    ''
    + (
      if loader != null then
        ''
          install -Dm755 opencode $out/libexec/opencode
          makeWrapper ${glibc}/lib/${loader} $out/bin/opencode \
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
