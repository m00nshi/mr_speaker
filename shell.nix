import sys
import io
import os
import time
import requests
import json
import subprocess
from faster_whisper import WhisperModel

# Initialize the Whisper model
model_id = os.getenv("WHISPER_MODEL")
model = WhisperModel(model_id)

# Read system prompt from file
with open("main.prompt", 'r') as file:
    sysprompt = file.read().strip()

# Initial chat setup
modelPath = os.getenv("NORTHERN_ENGLISH_MALE") + "/model.onnx"
system_prompt = {"role": "system", "content": sysprompt}
chat_history = []

def scribe(audio):
    segments, _ = model.transcribe(audio, beam_size=5, language="en", condition_on_previous_text=False, hallucination_silence_threshold=2, no_speech_threshold=0.5)
    sagos = list(segments)
    speech = ""
    for i in sagos:
        speech += i.text + "."
    return speech

def send_chat(system_prompt, current_prompt, chat_history, max_memory, api_url):
    chat_history.append({"role": "user", "content": current_prompt})
    if len(chat_history) > max_memory:
        chat_history = chat_history[-max_memory:]

    prompt = [system_prompt] + chat_history
    
    response = requests.post(
        api_url,
        headers={"Content-Type": "application/json"},
        data=json.dumps({"messages": prompt, "max_tokens": 256})
    )

    # Extract the assistant's response
    if response.status_code == 200:
        assistant_response = response.json().get('choices', [{}])[0].get('message', {}).get('content', '')
        chat_history.append({"role": "assistant", "content": assistant_response})
        print(assistant_response)
        return assistant_response
    else:
        print(f"Error: {response.status_code}")
        print(response.current_prompt)
        pass

while True:
    if os.path.exists("/tmp/piper_file"):
      os.remove("/tmp/piper_file")
      with open('/tmp/piper_file', 'w') as fp:
          pass
    if os.path.exists("/tmp/whisper_file"):
      os.remove("/tmp/whisper_file")
      with open('/tmp/whisper_file', 'w') as fp:
          pass

    # Start the subprocess
    cosrecord_process = subprocess.Popen(
        ['./pttplay/result/bin/cosrecord.sh', 'hw:2', '0D8C/0012', '-'],
        stdout=open("/tmp/whisper_file", 'wb')
    )
    
    # Wait for the subprocess to finish (if needed)
    cosrecord_process.wait()
    
    # Open the file and read its contents as bytes
    with open("/tmp/whisper_file", "rb") as f:
        file_content = f.read()
    
    # Create a BytesIO stream from the file content
    try:
        audio = io.BytesIO(file_content)
    except:
        continue
    
    speech = scribe(audio)

    if "Harry" in speech or "Potter" in speech:
        chat_history = []
        print("\n###\nBackdoor activated, resetting session state\n###\n", flush=True)
        continue

    if speech == "":
        continue
    
    print(speech, flush=True)
    sys.stdout.flush()
     
    #llamaApp = subprocess.Popen("./llamaapp.sh", stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    #generatedSpeech, err = llamaApp.communicate(input=(speech.encode() + b"\n"))
    generatedSpeech = send_chat(system_prompt, speech, chat_history, 100, "http://localhost:8080/v1/chat/completions")
    
    piper = subprocess.Popen(("piper", "-q", "--model", modelPath, "--output_file", "/tmp/piper_file"), stdin=subprocess.PIPE)
    piper.communicate(input=generatedSpeech.replace("<|eot_id|>", "").encode())

    # Send the speech data to the subprocess
    pttplay = subprocess.Popen(("./pttplay/result/bin/cosplay.sh", "hw:2", "0D8C/0012", "/tmp/piper_file"))

    # Wait for the subprocess to finish (if needed)
    pttplay.wait()


## Initialize the Whisper model
#model_id = os.getenv("WHISPER_MODEL")
#model = WhisperModel(model_id)
#
## Function to transcribe audio
#def scribe(audio):
#    segments, _ = model.transcribe(audio, beam_size=5, language="en", condition_on_previous_text=False)
#    sagos = list(segments)
#    speech = ""
#    for i in sagos:
#        speech += i.text + "."
#    return speech
#
## Read from stdin instead of a named pipe
#while True:
#    data = sys.stdin.buffer.read()
#    if not data:
#        time.sleep(0.1)  # Small delay to avoid busy-waiting
#        continue
#
#    audio = io.BytesIO(data)
#    sys.stderr.write("start transcription\n")
#    sys.stderr.flush()
#
#    speech = scribe(audio)
#    print(speech, flush=True)
#    sys.stdout.flush()
#

[astraluser@gabby:~/mr_speaker]$ cat shell.nix 
let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive//ad57eef4ef0659193044870c731987a6df5cf56b.tar.gz";
  }) {
    config.allowUnfree = true;
    config.cudaSupport = true;
  };

  myPython = pkgs.python3.withPackages (p: with p; [
    faster-whisper
    librosa
    numpy
    scikit-learn
  ]);


# could use bigger one
#  whisper_model = pkgs.fetchgit {
#    url = "https://huggingface.co/Systran/faster-whisper-tiny.en";
#    rev = "0d3d19a32d3338f10357c0889762bd8d64bbdeba";
#    sha256 = "sha256-Q5sg6UbLn7/V9eo65XnveObl49pK5y7DYxzx4pO254M=";
#    fetchLFS = true;
#  };
  whisper_model = pkgs.fetchgit {
    url = "https://huggingface.co/Systran/faster-whisper-large-v3";
    rev = "edaa852ec7e145841d8ffdb056a99866b5f0a478";
    sha256 = "sha256-WuTQAy9QLAR8Ggt41Qr2dHfw+21VFMbmEZ/jJXGQPis=";
    fetchLFS = true;
  };

# use mistral on fu1 
#  llamafile = pkgs.fetchurl {
#    url = "https://huggingface.co/Mozilla/Phi-3-mini-4k-instruct-llamafile/resolve/main/Phi-3-mini-4k-instruct.Q5_K_M.llamafile";
#    sha256 = "sha256-tl903HWLIEMPb8ww8SOp5IxYgM5piEFSHdlaxMkK8Hk=";
#    recursiveHash = true;
#    postFetch = ''
#      chmod +x $out
#    '';
#  };
#  llamafile = pkgs.fetchurl {
#    url = "https://huggingface.co/jartine/mistral-7b.llamafile/resolve/main/mistral-7b-instruct-v0.1-Q4_K_M.llamafile";
#    sha256 = "sha256-WiGeCvg9nK6hGVaSWBaJBzper0K+zCa1m3pGLibAFRg=";
#    recursiveHash = true;
#    postFetch = ''
#      chmod +x $out
#    '';
#  };
  llamafile = pkgs.fetchurl {
    url = "https://huggingface.co/Mozilla/Meta-Llama-3-8B-Instruct-llamafile/resolve/main/Meta-Llama-3-8B-Instruct.Q8_0.llamafile";
    sha256 = "sha256-Yuxw34NLGqDmcGn2/g8JdW6XTnOcG5qeNelruI52/3U=";
    recursiveHash = true;
    postFetch = ''
      chmod +x $out
    '';
  };
#  llamafile = pkgs.fetchurl {
#    url = "https://huggingface.co/Mozilla/Meta-Llama-3-8B-Instruct-llamafile/resolve/main/Meta-Llama-3-8B-Instruct.Q8_0.llamafile";
#    sha256 = "sha256-Yuxw34NLGqDmcGn2/g8JdW6XTnOcG5qeNelruI52/3U=";
#    recursiveHash = true;
#    postFetch = ''
#      chmod +x $out
#    '';
#  };
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
    screen
    piper-tts
    jq
    ffmpeg
    alsa-utils
    myPython
    cudaPackages.cuda_nvcc
    cudaPackages.cudatoolkit
    cudaPackages.cuda_cudart.static
  ];
  WHISPER_MODEL = whisper_model;
  NORTHERN_ENGLISH_MALE = northern_english_male;
  shellHook = ''
    echo "run ${llamafile} -ngl 9999"
  '';
  LD_LIBRARY_PATH =  "${pkgs.stdenv.cc.cc.lib}/lib:/run/opengl-driver/lib";


}
