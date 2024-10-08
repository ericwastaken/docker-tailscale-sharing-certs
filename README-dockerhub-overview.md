# Tailscale Sidecar Container for Sharing Certificates

This Docker image is designed to act as a sidecar container, facilitating secure Tailscale networking within your Docker Compose stack. It is based on the official Tailscale image and includes custom scripts to manage and periodically regenerate Tailscale certificates. The goal is to provide seamless integration for services requiring secure network communication over Tailscale.

## Features

- **Tailscale Integration:** Utilizes the official Tailscale image as the base.
- **Certificate Generation:** Automatically generates and updates Tailscale certificates.
- **Cron Jobs:** Manages cron jobs to regularly regenerate certificates weekly (Sunday at 4 AM).

## Scripts baked into the image

These are the key scripts included in the image once it is built:

- **ts-entrypoint.sh:** The main entrypoint script for the Docker container. It starts the Tailscale daemon, generates the initial certificate, and sets up the cron job to regenerate the certificate periodically.

- **ts-certgen.sh:** This script is invoked to generate a Tailscale certificate for the specified domain name. It should be run as a cron job to keep the certificate up to date. 
  
- **ts-manage-cron.sh:** Ensures that a cron job is set up to run `ts-certgen.sh` at regular intervals (every Sunday at 4 AM) to keep the certificate updated.

## How to share the certificates with other services

To share the certificates with other services in your Docker Compose stack, you can bind mount or use a volume pointing to the `/certs` directory. You will want to do this on the tailscale container and any other services that need access to the certificates. This will allow the other services to use the Tailscale certificates generated by this container.

The certificates will be given a name using the domain name specified in the `TS_HOST_FQDN` environment variable.

A typical example using Docker volumes would look like the following:

```yaml
services:
  # This is the Tailscale service that will host the Tailscale network and share the certificates with other services
  ts-nginx:
    image: ericwastakenondocker/tailscale-sharing-certs:latest
    container_name: ts-$TS_HOSTNAME
    restart: unless-stopped
    hostname: $TS_HOSTNAME
    environment:
      - TS_AUTHKEY=$TS_AUTHKEY
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_DOMAIN_NAME=$TS_HOST_FQDN
    volumes:
      # Persist Tailscale State so that the service can be restarted without losing the network authentication
      - ts-nginx-state:/var/lib/tailscale
      # Persist Tailscale Certificates so that other services can use them
      - ts-nginx-certs:/certs
      # Networking Juju
      - /dev/net/tun:/dev/net/tun
    # More networking Juju
    cap_add:
      - net_admin
      - sys_module

  # This is the service we want to expose on the Tailscale network
  nginx:
    image: nginx:latest
    container_name: ts-$TS_HOSTNAME-nginx
    restart: unless-stopped
    # Networking for this service is provided by the Tailscale service above
    network_mode: service:ts-nginx
    depends_on:
      - ts-nginx
    volumes:
      # Map in the persisted Tailscale Certificates
      - ts-nginx-certs:/certs
      # Map in the nginx configuration template (which has variables that need to be replaced)
      - ./nginx_conf/nginx-template.conf:/etc/nginx/nginx-template.conf:ro
    environment:
      - TS_HOST_FQDN=${TS_HOST_FQDN}
    # Change the entrypoint to use envsubst to replace the variables in the template for nginx.conf
    # This makes it easier to subst in the certificate names from Tailscale
    entrypoint: [
      "sh", "-c",
      "envsubst < /etc/nginx/nginx-template.conf > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"
    ]

# Persist the Tailscale State and Certificates
volumes:
  ts-nginx-state:
  ts-nginx-certs:
```

Notice:
- Environment variables are used which you should set in your `.env` file or in your Docker Compose file.
- The volume ts-nginx-ceets is used to share the certificates with the nginx service and is mapped into both services. You can call this volume whatever you like, so long as it's mapped properly inside the services that need it. For the tailscale service, it should be mapped to `/certs` and for the other services, it should be mapped to the directory where the certificates are needed by that other service.

## Examples

The `examples` directory contains examples of how to use the Tailscale sidecar container. Please refer to the README file in each example for the particular setup details for each.

Examples:
- [Tailscaled Nginx](https://github.com/ericwastaken/docker-tailscale-sharing-certs/tree/main/examples/tailscaled-nginx)

## GitHub

See the GitHub repo for more information including how to fork and build your own version.

https://github.com/ericwastaken/docker-tailscale-sharing-certs