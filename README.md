# Tailscale side-car container that shares certs with other services

This repository provides a custom Docker image based on the official Tailscale image. It is designed to serve as a sidecar container, enabling secure Tailscale networking within your Docker Compose stack. This image also includes scripts to manage and regenerate Tailscale certificates periodically.

## Available on Docker Hub

This container is available on Docker Hub at [ericwastakenondocker/tailscale-sharing-certs](https://hub.docker.com/r/ericwastakenondocker/tailscale-sharing-certs).

## Overview

This repository contains a Dockerfile and related scripts to create a custom Docker image that wraps the Tailscale client. The image serves as a sidecar container providing a secure Tailscale network for your services within a Docker Compose stack. It also includes cron jobs to ensure that Tailscale certificates are regularly updated.

## Features

- **Tailscale Integration:** Utilizes the official Tailscale image as the base.
- **Certificate Generation:** Automatically generates and updates Tailscale certificates.
- **Cron Jobs:** Manages cron jobs to regularly regenerate certificates weekly (Sunday at 4 AM).

## Getting Started

To build this image, use the included `x_build.sh` script. The script will build the container and tag it with the version number in the `build-manifest.env` file. Edit the manifest file to change the version number and image name as needed. The build script supports a multi-architecture build using the `buildx` feature of Docker.

When you're ready to publish the image to Docker Hub, use the `x_deploy.sh` script. This script will tag "latest" and push the image to the Docker Hub repository specified in the `build-manifest.env` file. The deploy script supports a multi-architecture push using the `buildx` feature of Docker.

## Scripts baked into the image

These are the key scripts included in the image once it is built:

- **ts-entrypoint.sh:** The main entrypoint script for the Docker container. It starts the Tailscale daemon, generates the initial certificate, and sets up the cron job to regenerate the certificate periodically.

- **ts-certgen.sh:** This script is invoked to generate a Tailscale certificate for the specified domain name. It should be run as a cron job to keep the certificate up to date. 
  
- **ts-manage-cron.sh:** Ensures that a cron job is set up to run `ts-certgen.sh` at regular intervals (every Sunday at 4 AM) to keep the certificate updated.

## Examples

The `examples` directory contains examples of how to use the Tailscale sidecar container. Please refer to the README file in each example for the particular setup details for each.

Examples:
- [Tailscaled Nginx](examples/tailscaled-nginx/README.md)

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes. 

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.