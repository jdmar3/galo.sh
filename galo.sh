#!/bin/bash
# Set dependency check variables
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
# Show help
show_help () {
  printf -- "Usage: $0 [options] -[n|s] LATITUDE -[e|w] LONGITUDE -z TIME_ZONE\n"
  printf -- "\n"
  printf -- "  -h\t\tShow this help message and exit.\n"
  printf -- "  -n, -s\tLatitude: N positive; S negative.\n"
  printf -- "  -e, -w\tLongitude: E positive; W negative.\n"
  printf -- "  -z\t\tTime zone: uses /etc/timezone by default.\n"
  printf -- "  -d 0-6\tDay to retrieve weather: 0 is today; defaults to 1.\n"
  printf -- "  -v\t\tVerbose output: returns full weather forecast.\n"
  printf -- "  -j\t\tEcho pretty JSON from open-meteo API and exit.\n"
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
  echo ${DATA} | jq
  exit 0
}
# Handle errors
dump () {
  echo "ERROR: $*." >&2
  exit 1
}
# Set latitude and longitude option default
OPT_N=false
OPT_S=false
OPT_E=false
OPT_W=false
# Set verbose var default
VERBOSE=false
# Set path for resource file
RESOURCE_PATH="/home/$USER/.galoshrc"
# Parse command line options
while getopts ":z:n:s:e:w:d:hjv" opt; do
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
      if (( "$OPTARG" >= "0" && "$OPTARG" <= "6" )); then
        DAY=$OPTARG
      else
        dump "Day option -d must be 0-6"
      fi
      ;;
    h )
      show_help
      ;;
    j )
      JSON_ONLY=true
      ;;
    v )
      VERBOSE=true
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
  if [ -e $RESOURCE_PATH ]; then
    . $RESOURCE_PATH
  else
    dump "Must specify both LATITUDE and LONGITUDE"
  fi
fi
# Set default time zone from system
if [ ! "$TZ" ]; then 
  TZ=$(cat /etc/timezone)
fi
# Set default day to tomorrow
if [ ! "$DAY" ]; then
  DAY=1
fi
# Update resource file
tee $RESOURCE_PATH << the_end >/dev/null
LAT=${LAT}
LONG=${LONG}
the_end
# Get JSON
DATA=$(getdata)
# Extract current weather variables
CURRENT_TIME=$(jq -r -c ".current_weather.time" <<< ${DATA})
CURRENT_TEMP=$(jq -r -c ".current_weather.temperature" <<< ${DATA})
CURRENT_WIND_SPEED=$(jq -r -c ".current_weather.windspeed" <<< ${DATA})
CURRENT_WIND_DIRECTION=$(jq -r -c ".current_weather.winddirection" <<< ${DATA})
CURRENT_WEATHERCODE=$(jq -r -c ".current_weather.weathercode" <<< ${DATA})
# Extract forecast variables
TIME=$(jq -r -c ".daily.time[${DAY}]" <<< ${DATA})
SUNSET=$(jq -r -c ".daily.sunset[${DAY}]" <<< ${DATA})
SUNRISE=$(jq -r -c ".daily.sunrise[${DAY}]" <<< ${DATA})
PRECIP_HOURS=$(jq -r -c ".daily.precipitation_hours[${DAY}]" <<< ${DATA})
PRECIP_SUM=$(jq -r -c ".daily.precipitation_sum[${DAY}]" <<< ${DATA})
WIND_GUSTS=$(jq -r -c ".daily.windgusts_10m_max[${DAY}]" <<< ${DATA})
WIND_DIRECTION=$(jq -r -c ".daily.winddirection_10m_dominant[${DAY}]" <<< ${DATA})
WIND_SPEED=$(jq -r -c ".daily.windspeed_10m_max[${DAY}]" <<< ${DATA})
TEMP_LOW=$(jq -r -c ".daily.temperature_2m_min[${DAY}]" <<< ${DATA})
WEATHERCODE=$(jq -r -c ".daily.weathercode[${DAY}]" <<< ${DATA})
TEMP_HIGH=$(jq -r -c ".daily.temperature_2m_max[${DAY}]" <<< ${DATA})
PRECIP_HOURS_UNIT=$(jq -r -c ".daily_units.precipitation_hours" <<< ${DATA})
PRECIP_SUM_UNIT=$(jq -r -c ".daily_units.precipitation_sum" <<< ${DATA})
WIND_GUSTS_UNIT=$(jq -r -c ".daily_units.windgusts_10m_max" <<< ${DATA})
WIND_DIRECTION_UNIT=$(jq -r -c ".daily_units.winddirection_10m_dominant" <<< ${DATA})
WIND_SPEED_UNIT=$(jq -r -c ".daily_units.windspeed_10m_max" <<< ${DATA})
TEMP_LOW_UNIT=$(jq -r -c ".daily_units.temperature_2m_min" <<< ${DATA})
TEMP_HIGH_UNIT=$(jq -r -c ".daily_units.temperature_2m_max" <<< ${DATA})
WEATHERCODE_UNIT=$(jq -r -c ".daily_units.weathercode" <<< ${DATA})
# Set day reference phrase
if (( "$DAY" == "0" )); then
  DAY_PHRASE="today"
elif (( "$DAY" >= "2" )); then
  DAY_PHRASE="in ${DAY} days"
else
  DAY_PHRASE="tomorrow"
fi
# Output JSON
if [[ "$JSON_ONLY" == true ]]; then
  show_json
  exit 0
else
# Do you need to wear your galoshes?
if (( "$PRECIP_HOURS" > "0" )); then
  printf "You might need your galoshes ${DAY_PHRASE}.\n"
else
  printf "You probably won't need your galoshes ${DAY_PHRASE}.\n"
fi
# Show weather forecast and then the current weather
if [[ "$VERBOSE" == true ]]; then
  printf -- "\n";
  printf -- "Forecast for ${TIME}:\n";
  printf -- "\n";
  printf -- "\tHigh: ${TEMP_HIGH}${TEMP_HIGH_UNIT}\tLow: ${TEMP_LOW}${TEMP_LOW_UNIT}\n";
  printf -- "\tPrecipitation: ${PRECIP_SUM} ${PRECIP_SUM_UNIT} over ${PRECIP_HOURS} ${PRECIP_HOURS_UNIT}\n";
  printf -- "\tWind: ${WIND_SPEED} ${WIND_SPEED_UNIT} from ${WIND_DIRECTION}${WIND_DIRECTION_UNIT} with gusts up to ${WIND_GUSTS} ${WIND_GUSTS_UNIT} \n";
  printf -- "\tWMO weather code: ${WEATHERCODE}\n";
  printf -- "\tSunrise: ${SUNRISE}\n";
  printf -- "\tSunset: ${SUNSET}\n";
  printf -- "\n";
  printf -- "Current weather (${CURRENT_TIME}):\n";
  printf -- "\n";
  printf -- "\tTemperature: ${CURRENT_TEMP}${TEMP_HIGH_UNIT}\n";
  printf -- "\tWind: ${CURRENT_WIND_SPEED} ${WIND_SPEED_UNIT} from ${CURRENT_WIND_DIRECTION}${WIND_DIRECTION_UNIT}\n";
  printf -- "\tWMO weather code: ${CURRENT_WEATHERCODE}\n";
  exit 0
fi
fi
