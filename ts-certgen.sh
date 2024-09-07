#!/bin/sh

# This script is used to generate a Tailscale certificate for the specified domain name.
# It is intended to be run as a cron job on a regular basis to ensure that the certificate is always up to date.

# Verify that the required environment variables are set
if [ -z "$TS_DOMAIN_NAME" ]; then
    echo "Error: TS_DOMAIN_NAME environment variable is not set."
    exit 1
fi

# Generate Tailscale certificate
echo "Generating Tailscale Certificate for ${TS_DOMAIN_NAME}..."
cd /certs/ || exit
tailscale cert $TS_DOMAIN_NAME