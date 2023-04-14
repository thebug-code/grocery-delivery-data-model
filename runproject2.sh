#!/bin/bash
# Copyright (c) 2012-2022, EnterpriseDB Corporation.  All rights reserved

# PostgreSQL psql runner script for Linux

# Verifica la linea de comandos
if [ $# -ne 0 -a $# -ne 1 ]; 
then
    echo 'Usage: $0 [wait]'
    exit 127
fi

echo "Ingrese el nombre de usuario de PostgreSQL:"
read user

while [ -z "$user" ]
do
  echo "El nombre de usuario no puede estar vacío. Ingrese el nombre de usuario de PostgreSQL:"
  read username
done

echo "Ingrese la contraseña de PostgreSQL:"
read -s password

while [ -z "$password" ]
do
  echo "La contraseña no puede estar vacía. Ingrese la contraseña de PostgreSQL:"
  read -s password
done

# Configura las variables de entorno
port='5432'
host='localhost'
database='BDP2_1810536_1610109'
export PGPASSWORD=$password

# Crea la base de datos
createdb \
        -h $host \
        -p $port \
        -U "$user" \
        "$database"

# Importa y lee los *.sql
psql \
      -U "$user" \
      -d "$database" \
      -a -f "base_table.sql"

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
        -U "$user" \
        -d "$database"
else
  echo "No se eliminó la base de datos."
fi

echo "sql script successful"
exit 0
