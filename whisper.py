import io
import time
import subprocess 
import fcntl
import os
import librosa
import numpy as np

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


#DEVICE = "hw:0,0"
#cmd =  ["arecord", "-D", DEVICE, "-f", "S16_LE", "-t", "wav", "-r", "44100", "-c", "1", "-N"]

cmd = ["arecord", "-f", "S16_LE", "-t", "wav", "-r", "44100", "-c", "2", "-N"]

ps = subprocess.Popen(cmd, stdout=subprocess.PIPE)
flags = fcntl.fcntl(ps.stdout.fileno(), fcntl.F_GETFL)
fcntl.fcntl(ps.stdout, fcntl.F_SETFL, flags | os.O_NONBLOCK)

time.sleep(0.2)
block_size = 131072
expected_block_time = block_size / 44100
header = ps.stdout.read(44)

while True:
    start_time = time.time()  # Record the start time of each iteration
    chunk = ps.stdout.read(block_size)
    if chunk:
        print("yes this is data. length:", len(chunk), "bytes")
        chunk_file = io.BytesIO(header + chunk)
        y, sr = librosa.load(chunk_file, sr=None)
        zcr = librosa.feature.zero_crossing_rate(y) #, frame_length=512, hop_length=256)
        print("Amplitde")
        print(np.max(np.abs(y)))
        print("Zero Rate")
        print(np.max(zcr))
        # if amplitude and zero rate indicate speech 
        # add the chunks into a phrase until silence is detected again 
            # phrase += chunk
            # speech = scribe(binary_phrase)
    else:
        print("break a leg")
        time.sleep(0.2)
        continue
    
    processing_time = time.time() - start_time
    sleep_time = expected_block_time - processing_time
    if sleep_time > 0:
        time.sleep(sleep_time)
