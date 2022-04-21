#!/bin/bash

DEPCURL=$(which curl)
DEPJQ=$(which jq)

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

# Variables
LAT=35.92
LONG=-79.05
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

if [[ $TOMORROW_PRECIP > 0 ]]; then
    printf "You might need your galoshes tomorrow.\n"
else
    printf "You probably won't need your galoshes tomorrow.\n"
fi

#echo $DATA
