#!/bin/sh

dateDiff () {

	date=$( date -d "$1" +%s )
	containerDate=$( date -d "$3" +%s )
	echo "$(( (date - containerDate) / 86400))"

}

for argument in "$@"; do
	key=$( echo "${argument}" | cut -d '=' -f 1 )
	value=$( echo "${argument}" | cut -d '=' -f 2 )
	case $key in
		"--help" | "-h")
			echo " --status, -s = all, exited, created, running\n --time, -t = h(hour), d(day), m(month) " 
			;;
		"--status" | "-s")
			status="$value"
			;;
		"--time" | "-t")
			timeRange="$( echo  ${value%?} )"
			timeChoice="$( echo -n $value | tail -c 1 )"
			;;
	esac
done
			

docker ps -a | awk '{ print $1 }' | \
while read containerId; do
  if [ "$containerId" != "CONTAINER" ]; then
  	yourTime=$( date +"%Y-%m-%-d" )
	containerStatus=$( docker inspect -f '{{.State.Status}}' $containerId )

	if [ "$status" = "running" ]; then
		containerDate=$( docker inspect $containerId | grep "StartedAt" | awk '{ print $2 }' | cut -c 2-11 )

	elif [ "$status" = "created" ]; then
		containerDate=$( docker inspect -f '{{.Created}}' $containerId )	
	
	elif [ "$status" = "exited" ]; then 
		containerDate=$( docker inspect $containerId | grep "FinishedAt" | awk '{ print $2 }' | cut -c 2-11 )	
	fi

	diff=$( dateDiff "$yourTime" "$containerDate" "$timeChoice" )
	if [ "$diff" -le "$timeRange" ] && [ "$containerStatus" = "$status" ]; then
		catchedContainerId="$( docker rm -f "$containerId" )"
		echo "$catchedContainerId deleted"
	fi
  fi
done

