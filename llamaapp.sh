#!/usr/bin/env bash

sys="You are a vampire, called Edward, you struggle to resist eating humans but you are in love with the person you are talking to."
max_memory=10


##--------------------------------------
#logfile="logfile.log"
#screen -S llama_session -dm bash -c "cd .. && ./$llamafile -ngl 999 > \"$logfile\" 2>&1"
#echo "llama loaded"
##--------------------------------------
#close_session() {
#    screen -X -S llama_session quit
#    exit 0
#}
#trap close_session SIGINT
#
##--------------------------------------

system_prompt='{"role":"system", "content":"'"$sys"'"}'
chat=()

while IFS= read -r text ; do
    read -r -p "Enter the prompt: " text
    if [[ -z "$text" ]]; then
        break
    fi
    
    chat+=(', {"role":"user", "content":"'"$text"'"} ')

    len=${#chat[@]}
    
    if [ "$len" -gt "$max_memory" ]; then
	   chat=("${chat[@]:len-"$max_memory"}")
    fi

    prompt="[$system_prompt${chat[*]}]"

    response=$(curl -s http://localhost:8080/v1/chat/completions  -d "{ \"messages\": $prompt }" | jq -r '.choices[0].message.content')  
    echo "$response"
    
    chat+=(', {"role":"assistant", "content":"'"$response"'"} ')
done
