# galo.sh

A bash script that uses the open-meteo API to tell you whether or not you need to wear your galoshes tomorrow.

## Use

```
galo.sh [options]

--help, -h      Show this help message and exit.

--lat           Latitude of location. Stores or updates config variable in /home/$USER/.galosh.

--long          Longitude of location. Stores of updates config variable in /home/$USER/.galosh.

--now, -n       Get the weather now instead of tomorrow.

--verbose, -v   Verbose output (full weather forecast).

--debug, -d     Echo raw JSON from open-meteo API.
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
