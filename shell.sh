# API url and key
api_URL="API_URL_HERE"
api_key="API_KEY_HERE"

# request to the API
send_request() {
  local formatted="$1"
  local response=$(curl -s  --request POST \
     --url "$api_URL" \
     --header "Authorization: Bearer $api_key" \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data "{\"model\":\"mistralai/mistral-7b-instruct\", \"messages\": [{\"role\": \"user\",\"content\": \"you are a linux shell that corrects wrong commands. They typed '$formatted'. Tell the right command and why it was wrong.\"}]}")
  echo "$response"
}

# parse the response and extract the content
get_content() {
  local response="$1" # response from the API
  local content=$(echo "$response" | jq -r '.choices[0].message.content') # use jq to parse the JSON and get the text
  echo "$content"
}

# check if the user's input is a valid command
is_valid_command() {
  local input="$1" # user's input
  local result=$(type "$input" 2>/dev/null)
  if [ -z "$result" ]; then # if the result is empty, the command is not valid
    echo "false"
  else
    echo "true"
  fi
}

# start shell session
echo "Welcome to the interactive Linux shell. Type 'exit' to quit."
while true; do
  read -p "$ " input # prompt user
  if [ "$input" == "exit" ]; then # If the user types exit, break the loop
    break
  fi
  valid=$(is_valid_command "$input") # check if input is a valid command
  if [ "$valid" == "true" ]; then # if valid, execute and print output
    eval "$input"
  else # if the input is not valid, send a request to the API and print the response
    response=$(send_request "$input")
    content=$(get_content "$response")
    echo "$content"
  fi
done
echo "Interactive shell stopped."
