# README - NGINX and Tailscale Docker Compose Example

This repository contains a Docker Compose configuration that sets up an NGINX server behind a Tailscale network. The Tailscale service manages the authentication and provides SSL certificates, which are used by NGINX to serve a secure site.

This setup allows you to expose an NGINX server securely on a Tailscale network, leveraging Tailscale's automatic certificate management for TLS. It demonstrates a way to dynamically generate NGINX configurations using environment variables, making it easy to manage SSL certificates and other configuration variables.

## Requirements

Ensure you have Docker and Docker Compose installed on your system.

## Environment Variables

Before running the Docker Compose services, you need to set the following environment variables:

- **TS_AUTHKEY**: The Tailscale Authkey to use for the Tailscale service. This is required for the initial service setup or if you recreate the service.
- **TS_HOSTNAME**: The hostname to use for the Tailscale service.
- **TS_HOST_FQDN**: The Fully Qualified Domain Name (FQDN) to use for the Tailscale service.

You can set these environment variables in your shell or export them in a `.env` file:

### .env Example
```env
TS_AUTHKEY=your_tailscale_authkey
TS_HOSTNAME=your_hostname
TS_HOST_FQDN=your.fqdn.com
```

## File Structure

```
tailscaled-nginx/
├── docker-compose.yml
└── nginx_conf/
    └── nginx-template.conf
```

## Configuration Files

### `nginx-template.conf`

This template configuration for NGINX uses placeholders that will be replaced by actual environment variables during the container startup. This can be any valid nginx.conf and you can include any other environment variables you need to replace.

```nginx
user  nginx;
worker_processes  auto;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    types_hash_max_size 2048;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        server_name  ${TS_HOST_FQDN};

        # Redirect HTTP to HTTPS
        location / {
            return 301 https://$host$request_uri;
        }
    }

    server {
        listen       443 ssl;
        server_name  ${TS_HOST_FQDN};

        # SSL Configuration
        ssl_certificate     /certs/${TS_HOST_FQDN}.crt;
        ssl_certificate_key /certs/${TS_HOST_FQDN}.key;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
```

## Docker Compose Configuration

Refer to the file `docker-compose.yml` for the complete configuration.

### Overview

This setup involves deploying two Docker containers: one for Tailscale and one for NGINX. Tailscale handles network security and SSL certificate management, while NGINX serves web content over HTTPS using the certificates provided by Tailscale. The configuration ensures seamless integration and secure communication over the network.

Note that the image used for tailscale **ericwastakenondocker/tailscale-sharing-certs:latest** is responsible for sharing the certificates with the NGINX container. This image is a custom version of the official Tailscale image that includes a script to share the certificates with other containers and also includes a CRON job that checks for certificate validity on a regular basis. Refer to the main repository for more information on this custom image.

### Techniques and Concepts

1. **Environment Variable Substitution**:
   - The setup uses environment variables to dynamically configure service parameters such as authentication keys, hostname, and domain names. This allows for easy reuse and customization.

2. **Tailscale Service**:
   - A Tailscale service is deployed to handle the authentication and the creation of a secure, private network. It manages the SSL certificates needed for securing the NGINX service.
   - Tailscale state and certificates are persisted in named Docker volumes, which ensures that network authentication and certificates are not lost if the service is restarted.

3. **NGINX Service**:
   - The NGINX service uses the certificates generated by the Tailscale service to secure web traffic with HTTPS.
   - NGINX redirects HTTP traffic to HTTPS for secure communication.
   - Environment variables are substituted into the NGINX configuration template at runtime using the `envsubst` command. This allows the final configuration to include the correct certificate paths and other dynamic settings.

4. **Network Mode**:
   - The NGINX service uses `network_mode: service:ts-nginx`, which tells Docker to use the network namespace of the Tailscale service. This ensures that NGINX can communicate securely over the Tailscale network.

5. **Volumes**:
   - Docker volumes are used to persist Tailscale state and certificates across container restarts. This ensures that the Tailscale service can maintain its configuration and provide the necessary certificates to the NGINX service.
     - **ts-nginx-state**: Stores the Tailscale state so that the service can be restarted without losing network authentication.
     - **ts-nginx-certs**: Stores the Tailscale certificates to be used by the NGINX service.

6. **Entrypoint Modification**:
   - The entrypoint of the NGINX container is modified to run a shell command that uses `envsubst` to substitute environment variables in the NGINX configuration template before starting NGINX. This provides a flexible way to inject environment-specific configuration values into the NGINX config.

7. **Dependence Management**:
   - The NGINX service is set to depend on the Tailscale service, ensuring that Tailscale is fully up and running before NGINX attempts to start. This helps avoid potential issues with missing certificates or network configurations.

### Benefits

- **Dynamic Configuration**: Using environment variables and templates makes the setup highly flexible and adaptable to different environments and use cases.
- **Security**: Tailscale provides a secure communication channel and manages SSL certificates automatically, reducing the burden of manual security management.
- **Persistence**: Persisting state and certificates in Docker volumes ensures that critical information is not lost across container restarts, enhancing reliability.
- **Deployment Simplicity**: Docker Compose simplifies the deployment process by defining the entire multi-container setup in a single file, making it easier to manage and replicate.

This approach leverages Docker's capabilities to create a secure and flexible web server deployment that adapts to various environments without extensive manual intervention.

## Running the NGINX Example

To start the services, run the following command from the root of the tailscaled-nginx directory:

```sh
docker-compose up -d
```


