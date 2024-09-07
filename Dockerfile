# Use the official Tailscale image as the base
FROM tailscale/tailscale:latest

# Set environment variables
ENV TS_STATE_DIR=/var/lib/tailscale

# Create the directory for the Tailscale state
RUN mkdir -p /var/lib/tailscale

# Copy the entrypoint script into the container
COPY ts-entrypoint.sh /usr/local/bin/entrypoint.sh
# Copy additional helpers into the container
COPY ts-manage-cron.sh /usr/local/bin/ts-manage-cron.sh
COPY ts-certgen.sh /usr/local/bin/ts-certgen.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/ts-certgen.sh /usr/local/bin/ts-manage-cron.sh

# Set the entrypoint to the script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
