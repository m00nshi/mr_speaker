
#./pttplay/result/bin/cosrecord.sh hw:1 /dev/hidraw0 - | python whisper.py | ./llamaapp.sh |
piper -q --model $NORTHERN_ENGLISH_MALE/model.onnx --output-raw | ./pttplay/result/bin/cosplay.sh hw:1 /dev/hidraw0 - 
