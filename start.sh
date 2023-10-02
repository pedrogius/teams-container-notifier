#!/usr/bin/env bash

scriptFolder=$(dirname $0)
configs="${scriptFolder}/config.sh"
source $configs

containers=`docker ps -f status=running --format "{{.Names}}"`

notifiedFile="/tmp/notified_containers.txt"
[ ! -f $notifiedFile ] && touch $notifiedFile

for container in $listOfContainers
do
  if ! (echo $containers | grep -q $container )
  then 
    if ! (cat $notifiedFile | grep -q $container)
      echo "$container offline"
      message="Warning! The container $container is down!"

      # Create Adaptive Card payload
      cardPayload="{
        \"@context\": \"http://schema.org/extensions\",
        \"@type\": \"MessageCard\",
        \"themeColor\": \"FF0000\",
        \"title\": \"Container Status Alert\",
        \"text\": \"$message\",
        \"potentialAction\": [{
          \"@type\": \"OpenUri\",
          \"name\": \"View in Portainer\",
          \"targets\": [{
            \"os\": \"default\",
            \"uri\": \"http://portainer:9443\"
          }]
        }]
      }"

      curl -H "Content-Type: application/json" \
      -X POST \
      -d "$cardPayload" $teamsWebhookUrl

      # Mark the container as notified
      echo $container >> $notifiedFile
    fi
  else
    # If container is up and was previously notified as down
    if (cat $notifiedFile | grep -q $container)
    then
      echo "$container is back online"
      message="Good news! The container $container is back online!"
      
      # Create Adaptive Card payload for Teams & send notification
      cardPayload="{
        \"@context\": \"http://schema.org/extensions\",
        \"@type\": \"MessageCard\",
        \"themeColor\": \"28A745\",
        \"title\": \"Container Status Alert\",
        \"text\": \"$message\",
      }"

      curl -H "Content-Type: application/json" \
      -X POST \
      -d "$cardPayload" $teamsWebhookUrl

      # Remove container from the notified list
      sed -i "/$container/d" $notifiedFile
    fi
  fi
done

exit 0
