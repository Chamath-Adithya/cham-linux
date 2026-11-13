# Backup and recovery

Use Restic with an external filesystem and a separate offsite repository. Store the repository password or recovery key outside this laptop. A partition on an internal SSD is not an external backup.

Before an OS, firmware, driver or database migration:

1. Create consistent application/database dumps.
2. Run `backup/restic-backup.sh`.
3. Run `restic check` according to the maintenance schedule.
4. Restore the latest snapshot into a new directory with `backup/restic-restore-test.sh`.
5. Open representative files and restore database dumps to a disposable instance.

Git history, Timeshift-style snapshots and old kernels help with configuration rollback but do not replace data backups.
