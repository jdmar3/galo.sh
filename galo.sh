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
show_help () {
	printf "Usage: $0 [options] -l LATITUDE LONGITUDE -z TIME_ZONE\n"
	printf "\n"
  printf "-h  Show this help message and exit.\n"       
  printf "-l  Latitude and longitude of location (stores or updates config variable in /home/$USER/.galosh)\n"
  printf "-z  Time zone (uses /etc/timezone by default)\n"
  printf "-n  Get the weather now instead of tomorrow\n"
  printf "-v  Verbose output (full weather forecast for the week)\n"
  printf "-d  Echo raw JSON from open-meteo API\n"
	exit 0	
}


# Get one week of rain data from open-meteo.com
getdata () {
  curl -s -G \
    -d "latitude=${LAT}" \
    -d "longitude=${LONG}" \
    -d "daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,precipitation_hours,windspeed_10m_max,windgusts_10m_max,winddirection_10m_dominant" \
    -d "current_weather=true&temperature_unit=fahrenheit&windspeed_unit=mph&precipitation_unit=inch" \
    -d "timezone=${TZ}" \
    https://api.open-meteo.com/v1/forecast
}
# Output pretty JSON
show_json () {
  echo $(getdata) | jq
  exit 0
}

dump () {
  echo "ERROR: $*." >&2
  exit 1
}

OPT_N=false
OPT_S=false
OPT_E=false
OPT_W=false

# Parse command line options
while getopts ":hjz:n:s:e:w:" opt; do
  case ${opt} in
    z )
      TZ=$OPTARG
      ;;
    n )
      OPT_N=true
      if [ "$OPT_S" == true ] ; then 
        dump "Cannot specify LATITUDE twice"
      else
        LAT=$(tr -d '-' <<< $OPTARG)
      fi
      ;;
    s )
      OPT_S=true
      if [ "$OPT_N" == true ] ; then
        dump "Cannot specify LATITUDE twice"
      else
        LAT=-$(tr -d '-' <<< $OPTARG)
      fi
      ;;
    e )
      OPT_E=true
      if [ "$OPT_W" == true ] ; then
        dump "Cannot specify LONGITUDE twice"
      else
        LONG=$(tr -d '-' <<< $OPTARG)
      fi
      ;;
    w )
      OPT_W=true
      if [ "$OPT_E" == true ] ; then
        dump "Cannot specify LONGITUDE twice"
      else
        LONG=-$(tr -d '-' <<< $OPTARG)
      fi
      ;;
    h )
      show_help
      ;;
    j )
      show_json
      ;;
    \? )
      dump "Invalid option: -$OPTARG\n"
      exit 1
      ;;
    : )
      echo "no options"
      exit 0
      ;;
  esac
done
# Check for resource file and if it doesn't exist, 
if [[ "$OPT_N" == false && "$OPT_S" == false ]] || [[ "$OPT_E" == false && "$OPT_W" == false ]]; then
  if [ -e /home/$USER/.galoshrc ]; then
    . /home/$USER/.galoshrc
  else
    dump "Must specify both LATITUDE and LONGITUDE"
  fi
fi

# Variables
#LAT=35.90949
#LONG=-79.0469
if [ ! $TZ ]; then 
  TZ=$(cat /etc/timezone)
fi
# Update resource file  
echo "LAT=${LAT}\nLONG=${LONG}\n" >> /home/$USER/.galoshrc

#TOMORROW_PRECIP=$(jq -c '.daily.precipitation_sum[1]' <<< ${DATA})

#if [[ ${TOMORROW_PRECIP} > 0 ]]; then
#  printf "You might need your galoshes tomorrow.\n"
#else
#  printf "You probably won't need your galoshes tomorrow.\n"
#fi
