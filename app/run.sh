#!/bin/bash
export PW=Sidearm12345
mc alias set s3 http://s3:9000 sidearm $PW
mc mb -p s3/gamestreams
mc mb -p s3/boxscores
mssql-cli -S mssql -U sa -P $PW -d master -i /app/0_create_db.sql
mssql-cli -S mssql -U sa -P $PW -d sidearmdb -i /app/1_create_tables_data.sql
python3 /app/stream.py