# Models directory

This is a organized subfolders with a blank `__init__.py` file eache one that represents a DSN connection.

This is builded automatily by monitor option by the admin.

    └─ your_project
      ├─ .cache
      ├─ apis
      ├─ conf
      ├─ models
      │  ├─ dns_name_to_mysql_db
      │  │  ├─ dbs
      │  │  │  ├─ db_name_1
      │  │  │  │  ├─ events
      │  │  │  │  │  └─ event_name
      │  │  │  │  │     └─ __init__.py, dump.py, main.py
      │  │  │  │  ├─ functions
      │  │  │  │  │  └─ function_name
      │  │  │  │  │     └─ __init__.py, dump.py, main.py
      │  │  │  │  ├─ procedures
      │  │  │  │  │  └─ procedure_name
      │  │  │  │  │     └─ __init__.py, dump.py, main.py
      │  │  │  │  ├─ queries
      │  │  │  │  │  └─ query_hash
      │  │  │  │  │     └─ __init__.py, dump.py, main.py
      │  │  │  │  ├─ sequences
      │  │  │  │  │  └─ sequence_name
      │  │  │  │  │     └─ __init__.py, dump.py, main.py
      │  │  │  │  ├─ tables
      │  │  │  │  │  └─ table_name
      │  │  │  │  │     └─ __init__.py, dump.py, main.py
      │  │  │  │  ├─ triggers
      │  │  │  │  │  └─ trigger_name
      │  │  │  │  │     └─ __init__.py, dump.py, main.py
      │  │  │  │  └─ views
      │  │  │  │     └─ view_name
      │  │  │  │        └─ __init__.py, dump.py, main.py
      │  │  │  └─ db_name_2
      │  │  ├─ roles
      │  │  │  ├─ role_name1_privileges.json
      │  │  │  └─ role_name2_privileges.json
      │  │  ├─ servers.json
      │  │  └─ users
      │  │     ├─ domain_name1
      │  │     │  ├─ user_name1
      │  │     │  │  ├─ roles.json
      │  │     │  │  └─ privileges.json
      │  │     │  └─ user_name2
      │  │     │     └─ privileges.json
      │  │     └─ domain_name2
      │  │        └─ user_name1
      │  │           └─ privileges.json
      │  ├─ dns_name_to_oracle_db
      │  │  └─ dbs
      │  │     └─ owner_name
      │  │        └─ db_name
      │  └─ dns_name_to_file
      │     ├─ schema_csv.json
      │     └─ schema_xml.xls
      ├─ templates
      └─ views
