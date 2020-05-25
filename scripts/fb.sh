#!/bin/sh

youtube-dl "$1" --add-metadata -o "fb" --print-json > fb.json

! [ -z "$2" ] && title=$2 || title=$(jq -r ".uploader" fb.json)

webpageUrl=$(echo $(jq -r ".webpage_url" fb.json))

if [[ $webpageUrl == *"/groups/"* ]]
  then
    groupDescription=$(echo $(jq -r ".title" fb.json))

    # below for loop basically gets only the group name
    # `groupDescription` is a string with spaces so treat it as an array
    # then get only the name of the group in `<group name> has n members`
    # string split with spaces is pain in the fucking ass in bash so...
    groupName=""
    groupNameCompleted=""
    for word in $groupDescription
    do
      [ $word == "has" ] && groupNameCompleted=true
      [ -z "$groupNameCompleted" ] && groupName+=" $word"
    done

    uploader=$(jq -r ".uploader" fb.json)
    fbname="${groupName} - ${uploader}"
  else
    fbname=$(echo $webpageUrl | cut -d "/" -f 4)
fi

ext=$(jq -r ".ext" fb.json)
id=$(jq -r ".id" fb.json)
output="$fbname - $title - $id.$ext"

cp "fb.$ext" "$output"
[ -f fb.json ] && rm fb.json
[ -f "fb.$ext" ] && rm "fb.$ext"
