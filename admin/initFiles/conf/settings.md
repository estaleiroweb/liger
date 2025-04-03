# Settings JSON Explanation

This document describes the structure and purpose of the `settings.json` configuration file.

## Overview

The `settings.json` file contains various configuration parameters used by the application. It includes settings for security, debugging, localization, date/time formatting, and input formats.

## JSON Structure

```json
{
  "secret": null,
  "debug": false,
  "charset": "utf-8",
  "language": "pt_br",
  "time_zone": "America/Sao_Paulo",
  "tz": true,
  "formats": {
    "date": "N j, Y",
    "datetime": "N j, Y, P",
    "time": "P",
    "year_month": "F Y",
    "month_day": "F j",
    "short_date": "d/m/Y",
    "short_datetime": "d/m/Y P",
    "number": {
      "separator": {
        "decimal": ".",
        "thousand": ",",
        "group": 0
      }
    },
    "week": {
      "first_day": 0
    },
    "input": {
      "date": {
        "%Y-%m-%d": "2000-10-25",
        "%d/%m/%Y": "25/10/2000",
        "%m/%d/%Y": "10/25/2000",
        "%d/%m/%y": "25/10/00",
        "%m/%d/%y": "10/25/00",
        "%d %b %Y": "25 Oct 2000",
        "%d %b, %Y": "25 Oct, 2000",
        "%b %d %Y": "Oct 25 2000",
        "%b %d, %Y": "Oct 25, 2000",
        "%d %B %Y": "25 October 2000",
        "%d %B, %Y": "25 October, 2000",
        "%B %d %Y": "October 25 2000",
        "%B %d, %Y": "October 25, 2000"
      },
      "time": {
        "%H:%M:%S": "14:30:59",
        "%H:%M:%S.%f": "14:30:59.001200",
        "%H:%M": "14:30"
      }
    }
  }
}
```

## Key Descriptions

- `name`: Name of project. It is currently set to `null`.
- `secret`: A secret key used for cryptographic operations. It is currently set to `null`.
- `debug`: A boolean value indicating whether the application is in debug mode. Set to `false` for production environments.
- `charset`: The default character encoding used by the application. Set to `utf-8`.
- `language`: The language code for localization. Set to `pt_br` (Brazilian Portuguese).
- `time_zone`: The time zone for the application. Set to `America/Sao_Paulo`.
- `tz`: A boolean value to enable or disable the timezone display. Set to `true`.
- `formats`: An object containing formatting settings for dates, times, and numbers. <https://docs.python.org/library/datetime.html#strftime-behavior>
    - `date`: The format string for dates.
    - `datetime`: The format string for date and time.
    - `time`: The format string for times.
    - `year_month`: The format string for year and month.
    - `month_day`: The format string for month and day.
    - `short_date`: A shorter date format.
    - `short_datetime`: A shorter date and time format.
    - `number`:
      - `separator`:
        - `decimal`: The decimal separator.
        - `thousand`: The thousands separator.
        - `group`: The grouping size.
    - `week`:
      - `first_day`: The first day of the week (0 for Sunday).
    - `input`:
      - `date`: Various date format strings and example values.
      - `time`: Various time format strings and example values.

## Usage

This configuration file should be used to customize the application's behavior according to the specific deployment environment and localization requirements.
