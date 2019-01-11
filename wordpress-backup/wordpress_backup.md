# Wordpress Back-up


## Local backup with a shell script
----
*wordpress_backup.sh* is a shell script to backup your wordpress files and database on your server.
It is design for self hosted site on Linux server with admin rights.

## Features
----

- backup and compress wordpress files to a backup directory
- backup the database and compress it into a backup directory
- a different file is created for each backup
- the script delete automatically the old backups (configurable)
- log the error messages and success

## Settings
----

### Mandatory settings

You need to adjust the following settings to match your server configuration :

    WWW_PATH="/var/www/"
    SITE_NAME="wordpress"
    BCK_PATH="/home/user/backup/"
    DB_USER="wpuser"
    DB_PWD="password"
    DB_NAME="wordpress"
    DB_HOST="localhost"
    LOG_FILE="/var/log/backup/wordpress_backup.log"
    DELETETIME=30

**Explanation**

*WWW\_PATH* is the path to the directory containing the wordpress directory
*SITE\_NAME* is the name of your wordpress directory stored in the previous directory

*Example :*
With the default configuration, wordpress files are located in /var/www/wordpress

Separating the path in two variables helps the backup script to use the site name 
as a default folder in the tar.gz file, and to store the backups in a directory named
by the wordpress site name

### Optional settings

You may want to adjust other variables to suit your needs :

    BCK_DATE=$(date +"%Y-%m-%d-%H%M%S")
    BCK_FILE="bck-files-${SITE_NAME}-${BCK_DATE}.tar.gz"
    BCK_DB="bck-db-${SITE_NAME}-${BCK_DATE}.sql"
    BCK_DIR="${BCK_PATH}${SITE_NAME}"
    WP_DIR=${WWW_PATH}/${SITE_NAME}


## Usage
----

You need to add the execution right in order to execute the script

    sudo chmod +x wordpress_backup.sh

The user who execute the script needs to have access to :

- wordpress directory
- mysqldump
- backup directory (write permission)
- log directory (write permission)
- /tmp directory (write permission)

## Roadmap
----

**Limitations**

- You need to create the backup directory where to store the files
BCK_PATH="/home/user/backup/"
- You need to create the backup directory for the logs
LOG_FILE="/var/log/backup/wordpress_backup.log"

**Next steps**

- Create automatically the backup directory to store the files and for the log.
- Log the files that have been deleted
