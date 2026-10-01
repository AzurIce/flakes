# Step Code (step) — terminal coding agent harness by StepFun (阶跃星辰)
# https://github.com/stepfun-ai/Step-Code
#
# No npm package exists; install.sh downloads platform tarballs from
# https://static-openapi.stepfun.com/stepcode (nvfetcher scrapes the same
# latest.json manifest). Update with `nix develop -c nvfetcher -c
# packages/nvfetcher.toml -o packages/_sources -f step-code`. `step update`
# self-update can't write into the store — bump the flake instead.

{
  lib,
  stdenv,
  patchelf,
  glibc,
  gcc,
  sources,
}:

let
  inherit (sources.step-code-x86_64-linux) version;
  src = {
    x86_64-linux = sources.step-code-x86_64-linux.src;
    aarch64-linux = sources.step-code-aarch64-linux.src;
  }.${stdenv.hostPlatform.system} or (throw "step-code: unsupported system ${stdenv.hostPlatform.system}");

  # tools/fd is a glibc+libgcc dynamic ELF (tools/rg is static, `step` is left
  # alone — see below).
  runtimeLibs = lib.makeLibraryPath [
    glibc
    gcc.cc.lib
  ];
  ldArch = {
    x86_64-linux = "x86-64.so.2";
    aarch64-linux = "aarch64.so.1";
  }.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "step-code";
  inherit version src;

  # The tarball wraps everything in a step/ directory.
  sourceRoot = "step";

  nativeBuildInputs = [ patchelf ];

  # `step` is a Bun single-file executable: the compiled app is a payload
  # APPENDED after the ELF sections, and any ELF rewrite (autoPatchelf, strip)
  # silently drops it, leaving a plain `bun` behind. Leave it byte-identical —
  # it runs unpatched against NixOS's /lib64/ld-linux + /lib/libc.so.6 system
  # links (same mechanism the official install.sh relies on). Only tools/fd
  # and the dlopen'd clipboard .node get patched.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    # The binary resolves photon_rs_bg.wasm, theme/, assets/ and export-html/
    # from the directory of the running executable, so the whole tree must sit
    # together under lib/ and bin/step execs the real binary (keeps argv[0]-
    # based lookups working too).
    mkdir -p $out/lib/step-code
    cp -r . $out/lib/step-code/
    # examples/ is dev-only reference code whose pnpm-workspace symlinks
    # dangle outside the tarball and fail noBrokenSymlinks.
    rm -rf $out/lib/step-code/examples

    mkdir -p $out/bin
    cat > $out/bin/step <<EOF
    #!${stdenv.shell}
    exec $out/lib/step-code/step "\$@"
    EOF
    chmod +x $out/bin/step

    patchelf --set-interpreter "${glibc}/lib/ld-linux-${ldArch}" \
      --set-rpath "${runtimeLibs}" \
      "$out/lib/step-code/tools/fd"
    for node in "$out"/lib/step-code/node_modules/@mariozechner/clipboard/clipboard.*.node; do
      patchelf --set-rpath "${runtimeLibs}" "$node"
    done

    runHook postInstall
  '';

  # The unpatched binary can't execute inside the build sandbox (its
  # interpreter is the host's /lib64/ld-linux, absent there), so instead of
  # running it, assert the Bun SEA trailer — the first casualty of any ELF
  # rewrite — is still intact at the end of the file.
  installCheckPhase = ''
    tail -c 64 "$out/lib/step-code/step" | grep -q "Bun! ----"
  '';

  doInstallCheck = true;

  meta = {
    description = "Step Code (step) - terminal coding agent harness by StepFun";
    homepage = "https://github.com/stepfun-ai/Step-Code";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "step";
  };
}
