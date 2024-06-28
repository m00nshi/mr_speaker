{
  nixConfig = {
    bash-prompt = "[devshell]: ";
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/ad57eef4ef0659193044870c731987a6df5cf56b";
    pttplay-src = {
      url = "github:pkharvey/pttplay";
      flake = false;
    };
    llama-cpp.url = "github:ggerganov/llama.cpp";
    llama-gguf = {
      url = "file+https://huggingface.co/bartowski/dolphin-2.9.3-mistral-7B-32k-GGUF/resolve/main/dolphin-2.9.3-mistral-7B-32k-IQ4_XS.gguf";
      flake = false;
    };
  };
  outputs = { nixpkgs, pttplay-src, llama-cpp, llama-gguf, ... }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in
  {
    devShells.x86_64-linux.default = import ./utilities.nix {
      inherit pkgs llama-gguf;
      llama-cpp = llama-cpp.packages.x86_64-linux.vulkan;
      pttplay = (pkgs.callPackage pttplay-src {});
    };
  };
}
