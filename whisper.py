import sys
import io
import os

from faster_whisper import WhisperModel

model_id = os.getenv("WHISPER_MODEL")
model = WhisperModel(model_id)

def scribe(audio):
	segments, _ = model.transcribe(audio, beam_size=5, language="en", condition_on_previous_text=False)
	sagos = list(segments)
	speech = ""
	for i in sagos:
		speech += i.text + "."
	return speech


#def wav_to_bytes(wav_file):
#    with open(wav_file, 'rb') as f:
#        bytes_data = f.read(44)
#    return bytes_data
#
#wav_file = 'out.wav'
#header = wav_to_bytes(wav_file)

#while True:
##    print("this is python")
#    data = sys.stdin.buffer.read()
#    if not data:
#        continue
#    audio = io.BytesIO(data)
#    speech = scribe(audio)
#    print(speech)

pipe_in_path = "/tmp/whisper_pipe"

with open(pipe_in_path, 'rb') as pipe_in:
    while True:
        data = pipe_in.read()
        if not data:
            continue
        audio = io.BytesIO(data)
        print("start transription")
        speech = scribe(audio)
        print(speech)
        sys.stdout.flush()

