#!/bin/sh

# Export necessary environment variables
export TS_STATE_DIR=/var/lib/tailscale
export TS_AUTHKEY=$TS_AUTHKEY

# Start Tailscale daemon in the background
echo "Starting Tailscale Container Boot..."
env TS_STATE_DIR="$TS_STATE_DIR" TS_AUTHKEY="$TS_AUTHKEY" /usr/local/bin/containerboot &

# Wait for the daemon to be ready
echo "Waiting for Tailscale daemon to be ready..."
sleep 5  # Wait for a few seconds to ensure the daemon is up and running

# Generate Tailscale certificate for the first time
/usr/local/bin/ts-certgen.sh

# Add the cron job for ts-certgen.sh if not already there, so we can keep the certificate up to date
/usr/local/bin/ts-manage-cron.sh

# Keep the Tailscale daemon running in the foreground
wait -n
