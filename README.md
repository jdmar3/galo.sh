# galo.sh

A bash script that uses the [Open-Meteo API](https://open-meteo.com/en/docs#api-documentation) to tell you whether or not you need to wear your galoshes tomorrow.

## Usage

```
Usage: ./galo.sh [options] -[n|s] LATITUDE -[e|w] LONGITUDE -z TIME_ZONE

  -h            Show this help message and exit.
  -n, -s        Latitude: N positive; S negative.
  -e, -w        Longitude: E positive; W negative.
  -z            Time zone: uses /etc/timezone by default.
  -d 0-6        Day to retrieve weather: 0 is today; defaults to 1.
  -v            Verbose output: returns full weather forecast.
  -j            Echo pretty JSON from open-meteo API and exit.
```

## Dependencies

- curl
- jq

## Notes

If you wish to install this script system-wide, place it in /usr/local/bin/.

When this script runs, it will look for a resource file in /home/$USER/.galoshrc.

If it does not find this .galoshrc, it will be created and populated with the last used latitude and longitude.
.galoshrc will be updated every time the script runs so that you do not have to repeatedly enter the same coordinates.
