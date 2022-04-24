#!/bin/bash
# 
DEPCURL=$(which curl)
DEPJQ=$(which jq)
# Check for dependencies
if [ -z "$DEPCURL" ] || [ -z "$DEPJQ" ]; then
  printf "Dependencies not installed. Missing dependencies:\n"
  if [ -z "$DEPCURL" ]; then
    printf "\tcurl\t(https://curl.se/) \n"
  fi
  if [ -z "$DEPJQ" ]; then
    printf "\tjq\t(https://stedolan.github.io/jq/)\n"
  fi
  exit 1
fi
# Show help function
function show_help () {
	printf -- "Usage: $0 [options] -[n|s] LATITUDE -[e|w] LONGITUDE -z TIME_ZONE\n"
	printf -- "\n"
  printf -- "  -h\t\tShow this help message and exit.\n"
  printf -- "  -n, -s\tLatitude: N positive; S negative.\n"
  printf -- "  -e, -w\tLongitude: E positive; W negative.\n"
  printf -- "  -z\t\tTime zone: uses /etc/timezone by default.\n"
  printf -- "  -d 0-6\tDay to retrieve weather: 0 is today; defaults to 1.\n"
  printf -- "  -v\t\tVerbose output: returns full weather forecast.\n"
  printf -- "  -j\t\tEcho raw JSON from open-meteo API.\n"
#  return 0	
}

#if []; then
#
#elif [ -e /home/$USER/.galoshrc ]; then
#	. /home/$USER/.galoshrc
#else
#	
#fi

# Variables
LAT=35.90949
LONG=-79.0469
TZ=$(cat /etc/timezone)


# Get one week of weather data from open-meteo.com
function getdata () {
  curl -s -G \
    -d "latitude=${LAT}" \
    -d "longitude=${LONG}" \
    -d "daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,precipitation_hours,windspeed_10m_max,windgusts_10m_max,winddirection_10m_dominant" \
    -d "current_weather=true&temperature_unit=fahrenheit&windspeed_unit=mph&precipitation_unit=inch" \
    -d "timezone=${TZ}" \
    https://api.open-meteo.com/v1/forecast
}
# Output pretty JSON
function show_json () {
  echo ${DATA} | jq
}

dump () {
  echo "ERROR: $*." >&2
  exit 1
}

# Store JSON obeject from open-meteo
DATA=$(getdata)

LAT_IN_COUNT=0
LONG_IN_COUNT=0

# Parse run-then-exit options
while getopts ":hjz:n:s:e:w:" opt; do
  case ${opt} in
    z )
      TZ_IN=$OPTARG
      ;;
    n )
      [ "${LAT_IN_COUNT}" -ne "1" ] && dump "Must specify LATITUDE and LONGITUDE"
      LAT_IN_COUNT=$((($LAT_IN_COUNT + 1)))
      LAT_IN=$(tr -d '-' <<< $OPTARG)
      ;;
    s )
      [ "${LAT_IN_COUNT}" -ne "1" ] && dump "Must specify LATITUDE and LONGITUDE"
      LAT_IN_COUNT=$((($LAT_IN_COUNT + 1)))
      LAT_IN=-$(tr -d '-' <<< $OPTARG)
      ;;
    e )
      [ "${LONG_IN_COUNT}" -ne "1" ] && dump "Must specify LATITUDE and LONGITUDE"
      LONG_IN_COUNT=$((($LAT_IN_COUNT + 1)))
      LONG_IN=$(tr -d '-' <<< $OPTARG)
      ;;
    w )
      [ "${LAT_IN_COUNT}" -ne "1" ] && dump "Must specify LATITUDE and LONGITUDE"
      LONG_IN_COUNT=$((($LAT_IN_COUNT + 1)))
      LONG_IN=-$(tr -d '-' <<< $OPTARG)
      ;;
    h )
      show_help
      exit 0
      ;;
    j )
      show_json
      exit 0
      ;;
    \? )
      dump "Invalid option: -$OPTARG\n"
      exit 1
      ;;
  esac
done

echo "${LAT_IN} ${LONG_IN}"

#TARGET_PRECIP=$(jq -c ".daily.precipitation_sum["$TARGET_INDEX]" <<< ${DATA})

#if [[ ${TARGET_PRECIP} > 0 ]]; then
#  printf "You might need your galoshes tomorrow.\n"
#else
#  printf "You probably won't need your galoshes tomorrow.\n"
#fi
