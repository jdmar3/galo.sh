# galo.sh

A bash script that uses the open-meteo API to tell you whether or not you need to wear your galoshes tomorrow.

## Usage

```
galo.sh [options] -l LATITUDE LONGITUDE -z TIME_ZONE

-h  Show this help message and exit.

-l  Latitude and longitude of location. Stores or updates config variable in /home/$USER/.galosh.

-n  Get the weather now instead of tomorrow.

-v  Verbose output (full weather forecast for the week) 

-d  Echo raw JSON from open-meteo API.
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
