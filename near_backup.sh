#!/bin/bash

DATE=$(date +%Y-%m-%d-%H-%M)
DATADIR=/home/near/.near/data
BACKUPDIR=/home/near/backups/
TEXTFILE_COLLECTOR_DIR=/home/node_exporter/collector
LOG=/home/near/backups/backup_job.log
SERVICE_NAME=neard

write_metrics () {
	END="$(date +%s)"

 	cat << EOF > "$TEXTFILE_COLLECTOR_DIR/near_backup.prom.$$"
near_backup_last_run_seconds ${END}
near_backup_bytes ${BACKUP_SIZE}
EOF

  	mv "$TEXTFILE_COLLECTOR_DIR/near_backup.prom.$$" \
    	"$TEXTFILE_COLLECTOR_DIR/near_backup.prom"
}

mkdir $BACKUPDIR

sudo systemctl stop ${SERVICE_NAME}.service

wait

echo "NEAR node was stopped" | ts >> ${LOG}

if [ -d "$BACKUPDIR" ]; then
    echo "Backup started" | ts >> ${LOG}

    BACKUP_FILENAME=${BACKUPDIR}/data_${DATE}.tar.gz
    tar -czvf ${BACKUP_FILENAME} ${DATADIR}
    if (( $? )); then
		echo "Could not create backup" | ts >> ${LOG}
	else
		BACKUP_SIZE=$(ls -s1 ${BACKUP_FILENAME} | awk '{print $1}')
		write_metrics
    	echo "Backup completed" | ts >> ${LOG}
		PREV_BACKUP=$(ls -t ${BACKUPDIR} | grep data | tail -1)
		rm ${BACKUPDIR}/${PREV_BACKUP}
		echo "Previous backup removed ${PREV_BACKUP}" | ts >> ${LOG}
	fi

else
    echo "$BACKUPDIR is not created. Check your permissions." | ts >> ${LOG}
    exit 0
fi

sudo systemctl start ${SERVICE_NAME}.service

echo "NEAR node was started" | ts >> ${LOG}
