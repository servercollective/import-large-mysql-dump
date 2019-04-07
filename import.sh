#!/bin/bash

# Ask the user for dump file
unset FILE
while [[ ! -f $FILE ]]; do
    echo Please specify the path of your dump file.
    read FILE

    if [[ ! -f $FILE ]]; then
        if [[ -L $FILE ]]; then
            printf '%s is a broken symlink!\n' "$FILE"
        else
            printf '%s does not exist!\n' "$FILE"
        fi
        unset FILE
    fi
done

# Ask the user for database information
read -p "MySQL Host [localhost]: " HOST
HOST=${HOST:-localhost}

read -p "User [root]: " USER
USER=${USER:-root}

read -p "Password []: " PASSWORD
PASSWORD=${PASSWORD:-}

read -p "Port [3306]: " PORT
PORT=${PORT:-3306}

until mysql -h $HOST -u $USER -p $PORT -p$PASSWORD  -e ";" ; do
    echo Can\'t connect, please retry:
    
    read -p "MySQL Host [localhost]: " HOST
    HOST=${HOST:-localhost}

    read -p "User [root]: " USER
    USER=${USER:-root}

    read -p "Password []: " PASSWORD
    PASSWORD=${PASSWORD:-}

    read -p "Port [3306]: " PORT
    PORT=${PORT:-3306}
done

read -p "Database: " DB

# store start date to a variable
start=`date`

echo "Import started: OK"

ddl="set names utf8; "
ddl="$ddl set global net_buffer_length=1000000; "
ddl="$ddl set global max_allowed_packet=1000000000; "
ddl="$ddl SET foreign_key_checks = 0; "
ddl="$ddl SET UNIQUE_CHECKS = 0; "
ddl="$ddl SET AUTOCOMMIT = 0; "
# if your dump file does not create a database, select one
ddl="$ddl USE $DB; "
ddl="$ddl source $FILE; "
ddl="$ddl SET foreign_key_checks = 1; "
ddl="$ddl SET UNIQUE_CHECKS = 1; "
ddl="$ddl SET AUTOCOMMIT = 1; "
ddl="$ddl COMMIT ; "

echo "Import started: OK"

time mysql -h $HOST -u $USER -p $PORT -p$PASSWORD -e "$ddl"

# store end date to a variable
end=`date`

echo "Start import:$start"
echo "End import:$end"
