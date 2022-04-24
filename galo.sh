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
	printf "Usage: $0 [options] -l LATITUDE LONGITUDE -z TIME_ZONE\n"
	printf "\n"
  printf "-h  Show this help message and exit.\n"       
  printf "-l  Latitude and longitude of location (stores or updates config variable in /home/$USER/.galosh)\n"
  printf "-z  Time zone (uses /etc/timezone by default)\n"
  printf "-n  Get the weather now instead of tomorrow\n"
  printf "-v  Verbose output (full weather forecast for the week)\n"
  printf "-d  Echo raw JSON from open-meteo API\n"
	return 0	
}
# Parse help option
while getopts ":h" opt; do
  case ${opt} in
    h )
      show_help
      exit 0
      ;;
    \?)
      printf "Invalid option: -$OPTARG\n" 1>&2
      exit 1
      ;;
  esac
done    

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


# Get one week of rain data from open-meteo.com
function getdata_simple(){
  curl -s -G \
    -d "latitude=${LAT}" \
    -d "longitude=${LONG}" \
    -d "daily=precipitation_sum,precipitation_hours" \
    -d "temperature_unit=fahrenheit" \
    -d "windspeed_unit=mph" \
    -d "precipitation_unit=inch" \
    -d "timezone=${TZ}" \
    https://api.open-meteo.com/v1/forecast
}

DATA=$(getdata_simple)

TOMORROW_PRECIP=$(jq -c '.daily.precipitation_sum[1]' <<< ${DATA})

if [[ ${TOMORROW_PRECIP} > 0 ]]; then
  printf "You might need your galoshes tomorrow.\n"
else
  printf "You probably won't need your galoshes tomorrow.\n"
fi
