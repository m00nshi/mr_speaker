{ pkgs, llama-cpp, pttplay, llama-gguf }:
let

  myPython = pkgs.python3.withPackages (p: with p; [
    faster-whisper
  ]);

### CHOSE ONE OF THE WHISPER MODELS
### find more here : https://huggingface.co/Systran 
  whisper_model = pkgs.fetchgit {
    url = "https://huggingface.co/Systran/faster-whisper-tiny.en";
    rev = "0d3d19a32d3338f10357c0889762bd8d64bbdeba";
    sha256 = "sha256-Q5sg6UbLn7/V9eo65XnveObl49pK5y7DYxzx4pO254M=";
    fetchLFS = true;
  };
#  whisper_model = pkgs.fetchgit {
#    url = "https://huggingface.co/Systran/faster-whisper-large-v3";
#    rev = "edaa852ec7e145841d8ffdb056a99866b5f0a478";
#    sha256 = "sha256-WuTQAy9QLAR8Ggt41Qr2dHfw+21VFMbmEZ/jJXGQPis=";
#    fetchLFS = true;
#  };



### CHOSE ONE OF THE PIPER VOICE MODELS 
### find more here : https://huggingface.co/rhasspy/piper-voices
  northern_english_male = let
    model = pkgs.fetchurl {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_GB/northern_english_male/medium/en_GB-northern_english_male-medium.onnx";
      sha256 = "sha256-V6IZro5jiHPbfRiJMwS+UGnEKGjzkruVw/8X8GkNBok=";
    };

    config = pkgs.fetchurl {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_GB/northern_english_male/medium/en_GB-northern_english_male-medium.onnx.json";
      sha256 = "sha256-aVV+09l0RjRT6bDAndmaftDlK4uHtks1fb7rJUCpfUc=";
    };
  in pkgs.linkFarm "northern_english_male" [
    { name = "model.onnx"; path = model; }
    { name = "model.onnx.json"; path = config; }
  ];

 

in pkgs.mkShell.override { stdenv = pkgs.gcc11Stdenv; } {
  buildInputs = with pkgs; [
    piper-tts
    jq
    ffmpeg
    alsa-utils
    myPython
    pttplay
#    (callPackage ./pttplay/default.nix {})
#    cudaPackages.cuda_nvcc
#    cudaPackages.cudatoolkit
#    cudaPackages.cuda_cudart.static
  ];
  WHISPER_MODEL = whisper_model;
  NORTHERN_ENGLISH_MALE = northern_english_male;
  shellHook = ''
    echo "run ${llama-cpp}/bin/llama-server -m ${llama-gguf} -p 8080"
  '';
#  LD_LIBRARY_PATH =  "${pkgs.stdenv.cc.cc.lib}/lib:/run/opengl-driver/lib";

}
