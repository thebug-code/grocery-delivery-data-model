#!/bin/bash
# Copyright (c) 2012-2022, EnterpriseDB Corporation.  All rights reserved

# PostgreSQL psql runner script for Linux

# Verifica la linea de comandos
if [ $# -ne 0 -a $# -ne 1 ]; 
then
    echo 'Usage: $0 [wait]'
    exit 127
fi

read -p "Ingrese el nombre de usuario de PostgreSQL: " user

while [ -z "$user" ]
do
    read -p "El nombre de usuario no puede estar vacío. Ingrese el nombre de usuario de PostgreSQL: " user
done

read -sp "Ingrese la contraseña de PostgreSQL: " password

while [ -z "$password" ]
do
    read -sp "La contraseña no puede estar vacía. Ingrese la contraseña de PostgreSQL: " password
done

# Configura las variables de entorno
port='5432'
host='localhost'
database='BDP2_1810536_1610109'
export PGPASSWORD=$password

# Crea la base de datos
createdb \
        -h "$host" \
        -p "$port" \
        -U "$user" \
        "$database"

psql \
      -h "$host" \
      -p "$port" \
      -U "$user" \
      -d "$database" \
      -a -f "base_tables.sql"

psql \
      -h "$host" \
      -p "$port" \
      -U "$user" \
      -d "$database" \
      -c "\\copy us_cities from 'us_data/us_cities.csv' (format 'csv', header, quote '\"')"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy us_addresses(street, city, state, postal_code) from 'us_data/us_addresses.csv' DELIMITER ',' CSV HEADER;"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy us_first_names from 'us_data/us_names.csv' (format 'csv', header, quote '\"')"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy us_last_names from 'us_data/us_surnames.csv' (format 'csv', header, quote '\"')"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy area_codes(area_code, postal_code) FROM 'us_data/us_area_codes.csv' DELIMITER ',' CSV HEADER;"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy product_names(name) FROM 'us_data/product_names.csv' DELIMITER ',' CSV HEADER;"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy product_descriptions(description) FROM 'us_data/product_brands.csv' DELIMITER ',' CSV HEADER;"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy product_prices(price) FROM 'us_data/product_prices.csv' DELIMITER ',' CSV HEADER;"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy product_image_urls(image_url) FROM 'us_data/product_image_urls.csv' DELIMITER ',' CSV HEADER;"

# Inicia el servidor
psql \
      -X \
      -h "$host" \
      -p "$port" \
      -U "$user" \
      -d "$database"

psql_exit_status=$? 

if [ $psql_exit_status != 0 ]; 
then
    echo "psql failed while trying to run this sql script" 1>&2
    exit $psql_exit_status
fi

read -p "¿Desea eliminar la base de datos? (s/n): " respuesta

if [ "$respuesta" == "s" ]; then
  # Eliminar la base de datos
    dropdb \
        -h "$host" \
        -p "$port" \
        -U "$user" \
        "$database"
else
  echo "No se eliminó la base de datos."
fi

echo "sql script successful"
exit 0
