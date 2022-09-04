# near-backup-scripts

near_backup.sh is a cron script for backing up NEAR data folder.
The script writes prometheus metrics for monitoring cron job execution.

Set up metrics exporting by adding flag `--collector.textfile.directory=/home/node_exporter/collector` to node_exporter service file.
