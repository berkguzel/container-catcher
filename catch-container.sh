#!/bin/bash

dateDiff () {
	date=$( date -d "$1" +%s)
	containerDate=$( date -d "$2" +%s)
	echo "$(( (date - containerDate) / 86400))"
}

docker ps -a | awk '{ print $1 }' | \
while read containerId; do
  if [ "$containerId" != "CONTAINER" ]; then
  	containerDate=$( docker inspect $containerId | grep "FinishedAt" | awk '{ print $2 }' | cut -c 2-11 )
	yourTime=$( date +"%Y-%m-%-d" ) 
	diff=$(dateDiff "$yourTime" "$containerDate")
	
	if [ "$diff" -eq "0" ]; then
		huntedContainerId="$( docker rm "$containerId" )"
		echo "$huntedContainerId deleted"
	fi
  fi
done

