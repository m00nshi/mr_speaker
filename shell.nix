let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive//ad57eef4ef0659193044870c731987a6df5cf56b.tar.gz";
  }) {};

  myPython = pkgs.python3.withPackages (p: with p; [
    faster-whisper
    librosa
    numpy
    scikit-learn
  ]);


# could use bigger one
  whisper_model = pkgs.fetchgit {
    url = "https://huggingface.co/Systran/faster-whisper-tiny.en";
    rev = "0d3d19a32d3338f10357c0889762bd8d64bbdeba";
    sha256 = "sha256-Q5sg6UbLn7/V9eo65XnveObl49pK5y7DYxzx4pO254M=";
    fetchLFS = true;
  };

# use mistral on fu1 
  llamafile = pkgs.fetchurl {
    url = "https://huggingface.co/Mozilla/Phi-3-mini-4k-instruct-llamafile/resolve/main/Phi-3-mini-4k-instruct.Q5_K_M.llamafile";
    sha256 = "sha256-tl903HWLIEMPb8ww8SOp5IxYgM5piEFSHdlaxMkK8Hk=";
    recursiveHash = true;
    postFetch = ''
      chmod +x $out
    '';
  };

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

 

in pkgs.mkShell {
  buildInputs = with pkgs; [
    screen
    piper-tts
    jq
    ffmpeg
    alsa-utils
    myPython
#    cudaPackages.cuda_nvcc
#    cudaPackages.cudatoolkit
#    gcc11
#    cudaPackages.cuda_cudart.static
  ];
  WHISPER_MODEL = whisper_model;
  NORTHERN_ENGLISH_MALE = northern_english_male;
#  shellHook = ''
#    ${llamafile} &
#  '';
#  LD_LIBRARY_PATH =  "${pkgs.stdenv.cc.cc.lib}/lib:/run/opengl-driver/lib";


}
