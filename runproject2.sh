#!/bin/bash
# Copyright (c) 2012-2022, EnterpriseDB Corporation.  All rights reserved

# PostgreSQL psql runner script for Linux

# Verifica la linea de comandos
if [ $# -ne 0 -a $# -ne 1 ]; 
then
    echo 'Usage: $0 [wait]'
    exit 127
fi

# Lee el nombre de usuario de PostgreSQL para conectarse
read -p "Username [postgres]: " user

if [ -z "$user" ];
then
    echo "Por favor ingrese el nombre de usuario de PostgreSQL"
    exit 1
fi

# Lee la contraseña que se utilizará si el servidor exige la autenticación de contraseña
read -sp "Password: " password
echo '\\n'
if [ -z "$password" ];
then
    echo "Por favor ingrese la contraseña del usuario de PostgreSQL"
    exit 1
fi

# Configura las variables de entorno
port='5432'
host='localhost'
database='BDP2_1810536_1610109'

# Crea la base de datos
createdb \
        -O "$user" \
        -W "$password" \
        "$database"

# Importa y lee los *.sql
psql \
      -U "$user" \
      -W "$password" \
      -d "$database" \
      -a -f "base_table.sql"

# Inicia el servidor
psql \
    -X \
    -h "$host" \
    -p "$port" \
    -U "$user"
    -W "$password" "$database"

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
        -W "$password" "$database"
else
  echo "No se eliminó la base de datos."
fi

echo "sql script successful"
exit 0
