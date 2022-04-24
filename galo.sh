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
  printf -- "Usage: $0 [options] -[n|s] LATITUDE -[e|w] LONGITUDE -z TIME_ZONE\n"
  printf -- "\n"
  printf -- "  -h\t\tShow this help message and exit.\n"
  printf -- "  -n, -s\tLatitude: N positive; S negative.\n"
  printf -- "  -e, -w\tLongitude: E positive; W negative.\n"
  printf -- "  -z\t\tTime zone: uses /etc/timezone by default.\n"
  printf -- "  -d 0-6\tDay to retrieve weather: 0 is today; defaults to 1.\n"
  printf -- "  -v\t\tVerbose output: returns full weather forecast.\n"
  printf -- "  -j\t\tEcho raw JSON from open-meteo API.\n"
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
while getopts ":hjz:n:s:e:w:d:" opt; do
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
    d )
      if (( "$OPTARG" >= 0 && "$OPTARG" <= 6 )); then
        DAY=$OPTARG
      else
        dump "Day option -d must be 0-6"
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

if [ ! "$TZ" ]; then 
  TZ=$(cat /etc/timezone)
fi
# Update resource file  
echo "LAT=${LAT}\nLONG=${LONG}\n" >> /home/$USER/.galoshrc

DATA=$(getdata)

PRECIP=$(jq -c ".daily.precipitation_hours[${DAY}]" <<< ${DATA})

if [[ ${PRECIP} > 0 ]]; then
  printf "You might need your galoshes tomorrow.\n"
else
  printf "You probably won't need your galoshes tomorrow.\n"
fi
