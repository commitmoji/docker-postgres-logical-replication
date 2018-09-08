-- ALTER SYSTEM SET archive_command = 'cp /mnt/efs/db/wal_running/%f "%p"';
ALTER SYSTEM SET archive_command = '/home/postgres/bin/archive_command.sh %f "%p"';
ALTER SYSTEM SET archive_timeout = 60;