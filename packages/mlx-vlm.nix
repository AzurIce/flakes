{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  mlx,
  mlx-audio,
  transformers,
  jinja2,
  sentencepiece,
  miniaudio,
  tqdm,
  pillow,
  requests,
  llguidance,
  opencv-python,
  fastapi,
  python-multipart,
  starlette,
  uvicorn,
  websockets,
  numpy,
}:

buildPythonPackage rec {
  pname = "mlx-vlm";
  version = "0.6.16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Blaizzy";
    repo = "mlx-vlm";
    tag = "v${version}";
    sha256 = "1k82k2kfxhvbh8cw9vlskw8ri5pn3i1wx74zhc3ziswwl48kya6d";
  };

  build-system = [ setuptools ];

  dependencies = [
    mlx
    mlx-audio
    transformers
    # required by transformers' apply_chat_template, not declared upstream
    jinja2
    sentencepiece
    miniaudio
    tqdm
    pillow
    requests
    llguidance
    opencv-python
    fastapi
    python-multipart
    starlette
    uvicorn
    websockets
    numpy
  ];

  # tests pull models from HuggingFace and require a GPU
  doCheck = false;

  pythonImportsCheck = [ "mlx_vlm" ];

  meta = {
    description = "Inference and fine-tuning of Vision Language Models (VLMs) on your Mac using MLX";
    homepage = "https://github.com/Blaizzy/mlx-vlm";
    license = lib.licenses.mit;
    mainProgram = "mlx_vlm.generate";
    platforms = [ "aarch64-darwin" ];
  };
}
