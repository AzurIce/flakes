{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchurl,
  python,
}:

# nixpkgs builds mlx from source with MLX_BUILD_METAL=OFF (the Metal shader
# compiler is not available in the nix sandbox), which makes it CPU-only and
# unusable for real inference. The official PyPI wheel ships a precompiled
# Metal backend (split into the mlx-metal package since 0.26.5), so we package
# the wheels instead.
let
  # pure-data wheel containing the precompiled mlx.metallib, hard-required by
  # mlx on Darwin (mlx-metal==<mlx version>)
  mlx-metal = buildPythonPackage rec {
    pname = "mlx-metal";
    version = "0.32.0";
    format = "wheel";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/d6/ef/d74ae99cfe9ddb59fd08abd14f47754c3d199291a93756903fa595b31b8a/mlx_metal-${version}-py3-none-macosx_14_0_arm64.whl";
      hash = "sha256-W2SyCsJLDEAfSJ3gHoIJ7cTTchJSAfGTFObznjhTIqo=";
    };

    # plain unpack+install, no runtime deps
    dependencies = [ ];
    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "mlx";
  version = "0.32.0";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "cp314";
    python = "cp314";
    abi = "cp314";
    platform = "macosx_14_0_arm64";
    hash = "sha256-LuebH4wsKjKa/JXs59zgvnmNQ/PedxpjcNK5+XArvZo=";
  };

  dependencies = [ mlx-metal ];

  # mlx-metal ships the Metal backend (libmlx.dylib, mlx.metallib) as an
  # overlay on the `mlx/lib/` package dir, which pip merges into one
  # site-packages. With PYTHONPATH-based merging core.so's @rpath cannot
  # find libmlx.dylib, so copy the backend in physically.
  postInstall = ''
    cp -r ${mlx-metal}/${python.sitePackages}/mlx/lib $out/${python.sitePackages}/mlx/
  '';

  doCheck = false;

  pythonImportsCheck = [ "mlx" ];

  meta = {
    description = "Array framework for Apple silicon (official wheel with Metal support)";
    homepage = "https://github.com/ml-explore/mlx";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
