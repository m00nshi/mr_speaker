import sys
import io
import os
import time

import subprocess

from faster_whisper import WhisperModel

# Initialize the Whisper model
model_id = os.getenv("WHISPER_MODEL")
model = WhisperModel(model_id)

def scribe(audio):
    segments, _ = model.transcribe(audio, beam_size=5, language="en", condition_on_previous_text=False)
    sagos = list(segments)
    speech = ""
    for i in sagos:
        speech += i.text + "."
    return speech

#cosrecord = subprocess.Popen(("./pttplay/result/bin/cosrecord.sh", "hw:1", "/dev/hidraw0", "/tmp/whisper_file"), stdout=subprocess.PIPE)

while True:
    # Start the subprocess
    cosrecord_process = subprocess.Popen(
        ['./pttplay/result/bin/cosrecord.sh', 'hw:1', '/dev/hidraw0', '-'],
        stdout=open("/tmp/whisper_file", 'wb')
    )
    
    # Wait for the subprocess to finish (if needed)
    cosrecord_process.wait()
    
    # Open the file and read its contents as bytes
    with open("/tmp/whisper_file", "rb") as f:
        file_content = f.read()
    
    # Create a BytesIO stream from the file content
    audio = io.BytesIO(file_content)
    
    speech = scribe(audio)
    
    print(speech, flush=True)
    print(speech, flush=True)
    print(speech, flush=True)
    print(speech, flush=True)
    print(speech, flush=True)
    sys.stdout.flush()
    
    modelPath = os.getenv("NORTHERN_ENGLISH_MALE") + "/model.onnx"
    
    llamaApp = subprocess.Popen("./llamaapp.sh", stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    generatedSpeech, err = llamaApp.communicate(input=(speech.encode() + b"\n"))
    
    piper = subprocess.Popen(("piper", "-q", "--model", modelPath, "--output_file", "/tmp/piper_file"), stdin=subprocess.PIPE)
    piper.communicate(input=generatedSpeech.decode().encode())
    
    # Send the speech data to the subprocess
    
    pttplay = subprocess.Popen(("./pttplay/result/bin/cosplay.sh", "hw:1", "/dev/hidraw0", "/tmp/piper_file"))




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
