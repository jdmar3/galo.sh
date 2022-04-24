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

#echo "${LAT} ${LONG}" | tr -d '-'
#tr -d '-' <<< "${LAT} ${LONG}"

OPT_N=false
OPT_S=false
OPT_E=false
OPT_W=false
LAT_IN_COUNT=0
LONG_IN_COUNT=0

# Parse run-then-exit options
while getopts ":hjz:n:s:e:w:" opt; do
  case ${opt} in
    z )
      TZ_IN=$OPTARG
      ;;
    n )
      $OPT_S || [ ! $OPT_W -a ! $OPT_E ] && dump "Must specify LATITUDE and LONGITUDE"
      OPT_N=true
      LAT_IN=$(tr -d '-' <<< $OPTARG)
      ;;
    s )
      $OPT_N || [ ! $OPT_W -a ! $OPT_E ] && dump "Must specify LATITUDE and LONGITUDE"
      OPT_S=true
      LAT_IN=-$(tr -d '-' <<< $OPTARG)
      ;;
    e )
      $OPT_W || [ ! $OPT_N -a ! $OPT_S ] && dump "Must specify LATITUDE and LONGITUDE"
      OPT_E=true
      LONG_IN=$(tr -d '-' <<< $OPTARG)
      ;;
    w )
      $OPT_E || [ ! $OPT_N -a ! $OPT_S ] && dump "Must specify LATITUDE and LONGITUDE"
      OPT_W=true
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
