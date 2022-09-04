#!/bin/bash

BACKUPDIR=/home/near/backups/
SERVICE_NAME=neard

sudo su - near -c '/home/near/bin/neard --home ~/.near init --chain-id shardnet --download-genesis'
CURRENT_BACKUP=$(ls -t ${BACKUPDIR} | grep data | head -1)
sudo tar -xvf ${BACKUPDIR}/${CURRENT_BACKUP} --directory /home/near/.near
sudo chown -R near:near /home/near/.near
sudo systemctl start ${SERVICE_NAME}
