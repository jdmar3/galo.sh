# galo.sh

A bash script that uses the open-meteo API to tell you whether or not you need to wear your galoshes tomorrow.

## Usage

```
Usage: ./galo.sh [options] -[n|s] LATITUDE -[e|w] LONGITUDE -z TIME_ZONE

  -h            Show this help message and exit.
  -n, -s        Latitude: N positive; S negative.
  -e, -w        Longitude: E positive; W negative.
  -z            Time zone: uses /etc/timezone by default.
  -d 0-6        Day to retrieve weather: 0 is today; defaults to 1.
  -v            Verbose output: returns full weather forecast.
  -j            Echo pretty JSON from open-meteo API andn exit.
```

## Dependencies

- curl
- jq

## Install

If you wish to install this script so that it is available system-wide, the `install.sh` script will place the script in your `/usr/local/bin/` directory or in another directory specified by a command line argument `--path` (default path indicated below).

```
bash ./install.sh --path=/usr/local/bin/
```

## Uninstall

To uninstall, run the following (replacing the path below with the path where the script is installed on your system):

```
bash ./install.sh --uninstall --path=/usr/local/bin/
```
