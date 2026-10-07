# pi — terminal coding agent (https://pi.dev/)
#
# Upstream publishes a bun-compiled standalone binary per platform in the
# GitHub releases, so we ship that instead of nixpkgs' pi-coding-agent, which
# buildNpmPackage's the whole earendil-works/pi monorepo (fetchNpmDeps plus a
# tsgo compile of eight workspace packages) from scratch on every bump.
#
# Version + src come from packages/nvfetcher.toml (`just update`), one entry
# per platform release asset. The tarball unpacks to a single `pi/` directory,
# so stdenv's auto-detected sourceRoot already is that directory. The binary
# needs its siblings (package.json — it reads its own version from there —,
# docs, examples, native prebuilds, the photon wasm and the export-html
# templates) at runtime, so the whole tree goes to $out/libexec/pi while
# $out/bin/pi is just a wrapper that adds ripgrep/fd to PATH.
#
# On Linux the ELFs are patchelf'd (autoPatchelfHook: retarget the interpreter
# at the nix glibc loader instead of /lib64/ld-linux-x86-64.so.2, and satisfy
# the libxcb prebuild), which the loader indirection otherwise needs. On darwin
# the Mach-O is copied as-is, keeping its code signature intact.

{ lib
, stdenvNoCC
, autoPatchelfHook
, makeWrapper
, ripgrep
, fd
, libxcb
, sources
}:

let
  version = sources.pi-x86_64-linux.version;
  src = {
    x86_64-linux = sources.pi-x86_64-linux.src;
    aarch64-linux = sources.pi-aarch64-linux.src;
    x86_64-darwin = sources.pi-x86_64-darwin.src;
    aarch64-darwin = sources.pi-aarch64-darwin.src;
  }.${stdenvNoCC.hostPlatform.system}
    or (throw "pi: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "pi";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];

  # native/linux/prebuilds/.../linux-platform-<arch>.node needs libxcb; the
  # bun-compiled ELF itself only needs libc (autoPatchelfHook maps that via
  # bintools' dynamic-linker, no explicit buildInput needed).
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ libxcb ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec
    cp -r . $out/libexec/pi
    chmod +x $out/libexec/pi/pi
    makeWrapper $out/libexec/pi/pi $out/bin/pi \
      --prefix PATH : ${lib.makeBinPath [ ripgrep fd ]} \
      --set-default PI_SKIP_VERSION_CHECK 1 \
      --set-default PI_TELEMETRY 0
    runHook postInstall
  '';

  # Bun-compiled executables must not be stripped.
  dontStrip = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    HOME=$TMPDIR $out/bin/pi --version | grep -qx "${version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Coding agent CLI with read, bash, edit, write tools and session management";
    homepage = "https://pi.dev/";
    changelog = "https://github.com/earendil-works/pi/releases/tag/v${version}";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "pi";
  };
}
