# Web JSON Explanation

This document describes the structure and purpose of the `web.json` configuration file, which defines settings for the web server, logging, file uploads, cookies, and URL transformations.

## JSON Structure

```json
{
  "webserver": {
    ":443": {
      "bind": "",
      "port": 443,
      "https": true,
      "keyfile": "/cer/key.pem",
      "certfile": "/cer/cert.pem",
      "router": ".roter"
    },
    ":80": {
      "bind": "",
      "port": 80,
      "redirect": ":443"
    }
  },
  "log": {
    "error": {},
    "info": {
      "format": "",
      "type": "file://tmp/"
    }
  },
  "upload": {
    "max_memory_size": 2621440,
    "temp_dir": null,
    "permissions": 644,
    "directory_permissions": 755
  },
  "cookie": {
    "name": "project",
    "age": null,
    "domain": null,
    "path": "/",
    "secure": false,
    "httponly": false,
    "samesite": null
  },
  "tr_url": [
    [
      "https?://[^/]+?/?",
      "/"
    ]
  ]
}
```

## Key Descriptions

- **`webserver`**:
  - Configuration for the web server.
    - **`:443`**: Settings for the HTTPS server.
      - **`bind`**: The IP address to bind to (empty string for all interfaces).
      - **`port`**: The port number (443 for HTTPS).
      - **`https`**: Boolean indicating if HTTPS is enabled (`true`).
      - **`keyfile`**: Path to the private key file.
      - **`certfile`**: Path to the certificate file.
      - **`router`**: Path to the router configuration.
    - **`:80`**: Settings for the HTTP server.
      - **`bind`**: The IP address to bind to.
      - **`port`**: The port number (80 for HTTP).
      - **`redirect`**: The URL to redirect HTTP requests to (HTTPS port 443).
- **`log`**:
  - Configuration for logging.
    - **`error`**: Settings for error logging (currently empty).
    - **`info`**: Settings for informational logging.
      - **`format`**: The log message format (currently empty).
      - **`type`**: The log output type (file at `/tmp/`).
- **`upload`**:
  - Configuration for file uploads.
    - **`max_memory_size`**: The maximum memory size for uploads (2621440 bytes).
    - **`temp_dir`**: The temporary directory for uploads (currently `null`).
    - **`permissions`**: File permissions for uploaded files (644).
    - **`directory_permissions`**: Directory permissions for uploaded files (755).
- **`cookie`**:
  - Configuration for cookies.
    - **`name`**: The cookie name ("project").
    - **`age`**: The cookie age in seconds (currently `null`).
    - **`domain`**: The cookie domain (currently `null`).
    - **`path`**: The cookie path ("/").
    - **`secure`**: Boolean indicating if the cookie should be secure (currently `false`).
    - **`httponly`**: Boolean indicating if the cookie should be HTTP-only (currently `false`).
    - **`samesite`**: The SameSite attribute of the cookie (currently `null`).
- **`tr_url`**:
  - Configuration for URL transformations.
    - An array of transformation rules, where each rule is an array of two strings:
      - The first string is a regular expression to match URLs.
      - The second string is the replacement string.
      - `[["https?://[^/]+?/?", "/"]]` : this line means that all http or https urls will be redirected to the root `/`

## Usage

This configuration file should be used to customize the web server's behavior, logging, file upload handling, cookie settings, and URL transformations.
