#!/bin/bash

# Backup Wordpress files and database
# Author : Christophe Nicault
# Date : 11/01/2019
# Copyright (c) 2019, under the Creative Commons Attribution-NonCommercial 3.0 Unported (CC BY-NC 3.0) License
# For more information see: https://creativecommons.org/licenses/by-nc/3.0/
# All rights reserved.

WWW_PATH="/var/www/"
BCK_PATH="/home/user/backup/"
DB_USER="wpuser"
DB_PWD="password"
DB_NAME="wordpress"
DB_HOST="localhost"
SITE_NAME="wordpress"
LOG_FILE="/var/log/backup/wordpress_backup.log"
DELETETIME=30
BREAKLINE="---------------------------------------------------------------------------------"

BCK_DATE=$(date +"%Y-%m-%d-%H%M%S")
BCK_FILE="bck-files-${SITE_NAME}-${BCK_DATE}.tar.gz"
BCK_DB="bck-db-${SITE_NAME}-${BCK_DATE}.sql"
BCK_DIR="${BCK_PATH}${SITE_NAME}"
WP_DIR=${WWW_PATH}/${SITE_NAME}


if [ ! -d $BCK_DIR -o ! -w $BCK_DIR ]
then
    echo $BREAKLINE >> $LOG_FILE
    echo "ERROR - $BCK_DATE - Backup directory $BCK_DIR is not a directory or is not writable" >> $LOG_FILE
    exit 1
fi

if [ ! -d ${WP_DIR} ]
then 
    echo $BREAKLINE >> $LOG_FILE
    echo "ERROR - $BCK_DATE - Wordpress directory does not exist or is not accessible" >> $LOG_FILE
    exit 2
fi

tar -czf ${BCK_DIR}/${BCK_FILE} -C $WWW_PATH $SITE_NAME 2> /tmp/tar_msg.err
tar_code=$?

echo $BREAKLINE >> $LOG_FILE
if [ $tar_code != 0 ]
then
    echo "ERROR - $BCK_DATE - failed to create archive $BCK_FILE in $BCK_DIR" >> $LOG_FILE
    echo "        Tar error code : $tar_code" >> $LOG_FILE
    echo "        Error message  :"$(cat /tmp/tar_msg.err) >> $LOG_FILE
    rm /tmp/tar_msg.err
    exit 3
else
    echo "SUCCESS - $BCK_DATE - Archive $BCK_FILE created successfully in $BCK_DIR" >> $LOG_FILE
fi

mysqldump -h${DB_HOST} -u${DB_USER} -p${DB_PWD} $DB_NAME > ${BCK_DIR}/${BCK_DB} 2> /tmp/sql_msg.err
sql_code=$?

gzip ${BCK_DIR}/${BCK_DB} 2> /tmp/gzip_msg.err
gzip_code=$?

echo $BREAKLINE >> $LOG_FILE
if [ $sql_code != 0 ]
then
    echo "ERROR - $BCK_DATE - failed to backup MySQL database" >> $LOG_FILE
    echo "        MySQL error code : $sql_code" >> $LOG_FILE
    echo "        Error message  :"$(cat /tmp/sql_msg.err) >> $LOG_FILE
    rm /tmp/sql_msg.err
    exit 4
elif [ $gzip_code != 0 ]
then
    echo "ERROR - $BCK_DATE - failed to compress MySQL backup" >> $LOG_FILE
    echo "        gzip error code : $gzip_code" >> $LOG_FILE
    echo "        Error message  :"$(cat /tmp/gzip_msg.err) >> $LOG_FILE
    rm /tmp/gzip_msg.err
else
    echo "SUCCESS - $BCK_DATE - Database successfully backed-up as file $BCK_FILE in $BCK_DIR" >> $LOG_FILE
fi

find $BCK_DIR -type f -mtime +$DELETETIME -exec rm {} \;
