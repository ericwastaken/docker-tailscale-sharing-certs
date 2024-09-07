#!/bin/sh

# Ensures a cron job is set up to run ts-certgen.sh on a regular basis

# Sunday 4 AM
CRON_JOB="0 4 * * 0 ts-certgen.sh >> /ts-certgen.log 2>&1"

# Check if the cron job already exists
if ! crontab -l | grep -Fxq "$CRON_JOB"; then
    echo "Adding cron job..."
    (crontab -l ; echo "$CRON_JOB") | crontab -
else
    echo "Cron job already exists."
fi
