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
echo ""

#read -p "Ingrese el número de clientes a generar: " number_of_customers
#while [ -z "$number_of_customers" ]
#do
#    read -p "El número de clientes no puede estar vacío. Ingrese el número de clientes a generar: " number_of_customers
#done
#
#read -p "Ingrese el numero de ordenes a generar: " number_of_orders
#while [ -z "$number_of_orders" ]
#do
#    read -p "El número de ordenes no puede estar vacío. Ingrese el número de ordenes a generar: " number_of_orders
#done
#
#read -p "Ingrese el numero de productos a generar: " number_of_items
#while [ -z "$number_of_items" ]
#do
#    read -p "El número de productos no puede estar vacío. Ingrese el número de productos a generar: " number_of_items 
#done
#
#read -p "Ingrese el promedio de productos por orden: " avg_items_per_order
#while [ -z "$avg_items_per_order" ]
#do
#    read -p "El promedio de productos no puede estar vacío. Ingrese el promedio de productos por orden: " promedio_productos
#done

# Configura las variables de entorno
port='5432'
host='localhost'
database='BDP2_1810536_1610109'
export PGPASSWORD=$password
number_of_customers=1000
number_of_orders=1000
number_of_items=1000
avg_items_per_order=5.0

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
      -a -f "tables_grocery_delivery.sql"

psql \
      -h "$host" \
      -p "$port" \
      -U "$user" \
      -d "$database" \
      -a -f "tables_grocery_delivery.sql"

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
     -c "\\copy us_status from 'us_data/us_status.csv' (format 'csv', header, quote '\"')"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -c "\\copy us_area_codes(area_code, postal_code) FROM 'us_data/us_area_codes.csv' DELIMITER ',' CSV HEADER;"

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
     -c "\\copy product_image_urls(image_url) FROM 'us_data/product_image_urls.csv' DELIMITER ',' CSV HEADER;"

psql \
     -h "$host" \
     -p "$port" \
     -U "$user" \
     -d "$database" \
     -f "spCreateTestData.sql"

# Llama a la función de carga de datos
psql \
      -h "$host" \
      -p "$port" \
      -U "$user" \
      -d "$database" \
      -c "CALL spCreateTestData($number_of_customers, $number_of_orders, $number_of_items, $avg_items_per_order);"

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
