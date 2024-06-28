# Local self-hosted ai chatbot over the radio.

wip

### What is this?

This is a funny project made by a few friends for EMF Camp 2024. It is a voice interactive AI chatbot that runs on a local computer and one can interact with it using a walkie-talkie.

For this you will need a special radio (code name umbiloFeng) that has been wired into a usb sound card - work of [@pkharvey](https://github.com/pkharvey/pttplay). This allows the program to read the state of the radio (receiving/transmitting/none) as well as initiate transmission.

### AI tools used

**[faster-whisper](https://github.com/SYSTRAN/faster-whisper)** : for speech to text

**[llamafile](https://github.com/mozilla-Ocho/llamafile)** : for response generation

**[piper](https://github.com/rhasspy/piper)** : for text to speech

### Install

1. Customise shell.nix to match the capabilities of your computer. 
    - Choose one of the whisper models (tiny works really well)
    - Choose one of the llamafile models to fit on your RAM or GPU memory
    - Choose one of the voices from piper
    - Uncomment cuda specific lines if you use Nvidia GPU
2. Plug in your umbiloFeng and swich it on. Enable all permissions for the devices that appers in /dev with `sudo chmod 777 /dev/hidraw*`. Note the new audio device and edit the `hw` and `hidraw` variables in the `whisper.py` script.
3. Do `nix-shell` to enter your dev shell.
4. Run the llamafile from it's path in the nix store. E.g. ` /nix/store/g723599pdiwvq3mz23g36d4ahnz0vvwr-Phi-3-mini-4k-instruct.Q5_K_M.llamafile`. Use `-ngl 9999` flag if you are using a GPU.
5. Do `nix-shell` again in another terminal window or put the previous process in the background.
6. Run `python whisper.py`. 
7. Edit `main.prompt` and repeat step 6 to change the system prompt.
8. Profit.

Alternatively use `nix develop` to use the flake. The flake uses llama.cpp with GGUF models.

### Notes

- To reset the chat and forget the previous conversation say 'Harry Potter'
- Set up rules in `main.prompt` and play games with your new friend.
- Be good on the radio. Find a free channel and adjust your power in order not to interfere with other communications.

#### Issues

- On some devices hidapitester can not read the state correctly via the /dev/hidrawX , one possibility is to replace `--open-path /dev/hidrawX`  with `--vidpid 0D8C/0012` when hidapitester is called. This will only work if you don't have another USB sound card of the same type plugged in.
