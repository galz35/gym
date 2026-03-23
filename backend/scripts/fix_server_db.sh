#!/bin/bash
# Script para corregir el acceso a la base de datos en el servidor

DB_NAME="gym_db"
DB_USER="alacaja"
DB_PASS="TuClaveFuerte"

echo "==> (1) Verificando si el usuario $DB_USER existe en PostgreSQL..."
USER_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")

if [ "$USER_EXISTS" != "1" ]; then
    echo "    Creando usuario $DB_USER..."
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
    sudo -u postgres psql -c "ALTER USER $DB_USER WITH SUPERUSER;" # Permisos para crear esquemas
else
    echo "    El usuario $DB_USER ya existe. Actualizando contraseña..."
    sudo -u postgres psql -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';"
fi

echo "==> (2) Verificando base de datos $DB_NAME..."
DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")

if [ "$DB_EXISTS" != "1" ]; then
    echo "    Creando base de datos $DB_NAME..."
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
else
    echo "    La base de datos $DB_NAME ya existe."
fi

echo "==> (3) Otorgando permisos sobre el esquema public y gym..."
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON SCHEMA public TO $DB_USER;"

echo "==> (4) Reiniciando proceso apig con PM2 para aplicar cambios de ENV..."
pm2 restart apig

echo "============================================="
echo " ✅ Permisos corregidos"
echo " Intenta de nuevo la prueba de conexión."
