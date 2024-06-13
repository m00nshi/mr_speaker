import sys
import io
import os
import time
import requests
import json
import subprocess
from faster_whisper import WhisperModel

hw = "hw:0"
#   CHOOSE CORRECT AUDIO DEVICE NUMBER
memory = 100

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
        ['cosrecord.sh', hw, '0D8C/0012', '-'],
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

    # say Harry Potter to clear chat history
    if "Harry" in speech or "Potter" in speech:
        chat_history = []
        print("\n###\nBackdoor activated, resetting session state\n###\n", flush=True)
        continue
    if speech == "":
        continue
    
    print(speech, flush=True)
   
    generatedSpeech = send_chat(system_prompt, speech, chat_history, memory, "http://localhost:8080/v1/chat/completions")
    
    piper = subprocess.Popen(("piper", "-q", "--model", modelPath, "--output_file", "/tmp/piper_file"), stdin=subprocess.PIPE)
    piper.communicate(input=generatedSpeech.replace("<|eot_id|>", "").encode())

    # Send the speech data to the subprocess
    pttplay = subprocess.Popen(("cosplay.sh", hw, "0D8C/0012", "/tmp/piper_file"))

    # Wait for the subprocess to finish (if needed)
    pttplay.wait()
