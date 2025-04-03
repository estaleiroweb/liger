# DSN JSON Explanation

This document describes the structure and purpose of the `dsn.json` configuration file, which defines settings for database connections and data source names.

## JSON Structure

```json
{
  "dsn_name": {
    "scheme": "mariadb",
    "host": "10.0.0.1",
    "user": "admin",
    "password": "plain_text_passwork",
    "crypt": "sha256..pass by crypt secrtet key in settings.json.",
    "database": "test",
    "monitor": 2,
    "dsn_write": "dsn_name_inherit"
  },
  "dsn_name_inherit": {
    "inherit": "dsn_name",
    "monitor": false,
    "port": 3307,
    "crypt": "sha256...overload atribute"
  },
  "doc": {
    "scheme": "mysql,mariadb,file,ssh,excel,oracle,mongodb,etc",
    "host": "ip,hostname",
    "port": "int,null",
    "user": "str,null",
    "password": "str,null",
    "crypt": "str,null",
    "database": "str,null",
    "query": {},
    "params": "str,null",
    "fragment": "str,null"
  }
}
```

## Key Descriptions

- **`dsn_name`**:
  - A data source name configuration.
    - **`scheme`**: The database scheme (e.g., "mariadb").
    - **`host`**: The database host address (e.g., "10.0.0.1").
    - **`user`**: The database username (e.g., "admin").
    - **`password`**: The database password (e.g., "plain_text_passwork").
    - **`crypt`**: The encrypted password (e.g., "sha256..pass by crypt secrtet key in settings.json.").
    - **`database`**: The database name (e.g., "test").
    - **`dsn_write`**: a reference to the doc key, to write the documentation for the key.
- **`dsn_name_inherit`**:
  - A data source name configuration that inherits settings from `dsn_name`.
    - **`inherit`**: The name of the data source to inherit from ("dsn_name").
    - **`port`**: Overrides the port from the inherited configuration (3307).
    - **`crypt`**: Overrides the crypt from the inherited configuration (e.g., "sha256...overload atribute").
- **`doc`**:
  - Documentation for the DSN configuration parameters.
    - **`scheme`**: Allowed schemes (e.g., "mysql,mariadb,file,ssh,excel,oracle,mongodb,etc").
    - **`host`**: Allowed host types (e.g., "ip,hostname").
    - **`port`**: Allowed port types (e.g., "int,null").
    - **`user`**: Allowed user types (e.g., "str,null").
    - **`password`**: Allowed password types (e.g., "str,null").
    - **`crypt`**: Allowed crypt types (e.g., "str,null").
    - **`database`**: Allowed database types (e.g., "str,null").
    - **`query`**: Allowed query types (e.g., "{}").
    - **`params`**: Allowed params types (e.g., "str,null").
    - **`fragment`**: Allowed fragment types (e.g., "str,null").

## Usage

This configuration file should be used to define and manage database connection settings. The `dsn_name_inherit` structure allows for inheritance and overriding of configurations, making it easier to manage multiple related data sources. The `doc` key serves as documentation for the allowed values of each key in the DSN's.
