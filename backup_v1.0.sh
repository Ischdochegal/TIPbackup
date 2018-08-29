#!/bin/bash
#
# Prorgam:          backup.sh
# Description:      The script is used to do a weekly full backup and daily incremental of the "/home" directory on to a external flash or hard drive. Automated with cron Deamon. Also gives user a pop up message when the drive can't be found, where the user can restart or abort the backup.
# Autor:            KEV
# Version:          1.0
# Date:             28.08.2018
#
# Start

# Todays date to name the file
DATE=$(date +%Y-%m-%d-%H%M)
# Local directory to backup
SOURCE_DIR="/home"
# Backup destination
BACKUP_DIR="/dev/sda1"
# Date of the last full backup
LAST_FULL_BACKUP=$(cat /tmp/date_full_backup)

# Checks if there's a connection to the backup directory and gives the user a popup window when there's a problem with the connection, where the user can restart or abort the backup.
if [[ ! -d "$BACKUP_DIR" ]]; then
# YAD Dialog
yad  --notification --title="Backup drive not found!" --text="Please check the connection to the drive!" --button="Restart backup" --button="Abort backup" --width=400 --height=300 --sticky  --center

# Save return value
ret=$?
# Interpret return value
if [[ $ret = 0 ]]
then
  # Checks if there's already a full backup (younger than 7 days), if not, it makes that first and if it exists, it will do an incremental backup.
  if [[ $(find "/tmp/date_full_home" -mtime -7 -print) ]]
  then
    #Script of the incremental backup of $SOURCE_DIR
    tar --listed-incremental=snapshot.file -cvpzf $BACKUP_DIR/inc_backup_$DATE.1.tar.gz $SOURCE_DIR
  else
    # Script of the full backup of $SOURCE_DIR
    echo $DATE > /tmp/date_full_backup
    tar --listed-incremental=snapshot.file --level=0 -cvpzf $BACKUP_DIR/full.backup.2.tar.gz $SOURCE_DIR
    exit 0
  fi
else
  exit 1
fi
fi

# Checks if there's already a full backup (younger than 7 days), if not, it makes that first and if it exists, it will do an incremental backup.
if [[ $(find "/tmp/date_full_backup" -mtime -7 -print) ]]
then
  #Script of the incremental backup level 1 (1) of $SOURCE_DIR
  tar --listed-incremental=snapshot.file -cvpzf $BACKUP_DIR/inc_backup_$DATE.1.tar.gz $SOURCE_DIR
else
  # Script of the full backup level 0 (2) of $SOURCE_DIR
  echo $DATE > /tmp/date_full_backup
  tar --listed-incremental=snapshot.file --level=0 -cvpzf $BACKUP_DIR/full.backup.2.tar.gz $SOURCE_DIR
fi


# End
