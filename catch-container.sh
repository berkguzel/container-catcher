#!bin/sh

dateDiff () {
	if [ "$2" = "h" ]; then
		date=$( date -d "$3" +%s )
		containerDate=$( date -d "$1" +%s)
		result=$(( (date - containerDate) / 86400))
		if [ "$result" -le "1" ]; then
			date=$( date  +"%T" )
			date=$( date -d "$date" +%s )
			containerDate=$( date -d "$4" +%s )
			echo "$(( (date - containerDate) / 3600))"
		fi
	else
		date=$( date +"%Y-%m-%-d" )
		date=$( date -d "$date" +%s )
		containerDate=$( echo "$1" | cut -c 1-10 )
		containerDate=$( date -d "$containerDate" +%s )
		echo "$(( (date - containerDate) / 86400))"
	fi
}

for argument in "$@"; do
	key=$( echo "${argument}" | cut -d '=' -f 1 )
	value=$( echo "${argument}" | cut -d '=' -f 2 )
	case $key in
		"--help" | "-h")
			echo " --status, -s = all, exited, created, running\n --time, -t = h(hour), d(day) " 
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
	case $containerStatus in
		"running")
			if [ "$timeChoice" = "h" ]; then
				containerDateH=$( docker inspect $containerId | grep "StartedAt" | awk '{ print $2 }' | cut -c 13-20 )
			fi
			containerDate=$( docker inspect $containerId | grep "StartedAt" | awk '{ print $2 }' | cut -c 2-11 )
			;;
		"created")
			if [ "$timeChoice" = "h" ]; then
				containerDateH=$( docker inspect -f '{{.Created}}' $containerId | cut -c 12-19 )
			fi
			containerDate=$( docker inspect -f '{{.Created}}' $containerId | cut -c 3-10 )
			;;
		"exited")
			if [ "$timeChoice" = "h" ]; then
				containerDateH=$( docker inspect $containerId | grep "FinishedAt" | awk '{ print $2 }' | cut -c 13-20 )
			fi	
			containerDate=$( docker inspect $containerId | grep "FinishedAt" | awk '{ print $2 }' | cut -c 2-11 )	
			;;
	esac
		
	diff=$( dateDiff "$containerDate" "$timeChoice" "$yourTime" "$containerDateH" )
	
	if [ "$diff" -le "$timeRange" ] && [ "$containerStatus" = "$status" ]; then
		catchedContainerId="$( docker rm -f "$containerId" )"
		echo "$catchedContainerId deleted"
	fi
  fi
done

