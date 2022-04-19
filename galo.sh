#!/bin/bash
# Get one week of rain data from open-meteo.com
curl -G -d 'latitude=35.92' -d 'longitude=-79.05' -d 'daily=precipitation_sum,precipitation_hours' -d 'temperature_unit=fahrenheit' -d 'windspeed_unit=mph' -d 'precipitation_unit=inch' -d 'timezone=America/New_York' https://api.open-meteo.com/v1/forecast
