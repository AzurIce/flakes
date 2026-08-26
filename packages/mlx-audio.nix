{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  huggingface-hub,
  miniaudio,
  mlx,
  numpy,
  scipy,
  sounddevice,
  tqdm,
  transformers,
}:

buildPythonPackage rec {
  pname = "mlx-audio";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Blaizzy";
    repo = "mlx-audio";
    tag = "v${version}";
    sha256 = "1bxj87p2cz3hv89nzyqdi9n51ymjsyrh2zmgiccjg17z49scdydr";
  };

  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    miniaudio
    mlx
    numpy
    scipy
    sounddevice
    tqdm
    transformers
  ];

  # tests pull models from HuggingFace and require a GPU
  doCheck = false;

  pythonImportsCheck = [ "mlx_audio" ];

  meta = {
    description = "Inference of text-to-speech (TTS) and speech-to-speech (STS) models locally on your Mac using MLX";
    homepage = "https://github.com/Blaizzy/mlx-audio";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
