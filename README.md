# agl-docker-worker

## Purpose

This repository contains some scripts to generate a Docker image suitable for AGL workers. 

The AGL worker image is a Docker image based on Debian 8 and contains the necessary tools
either to build platform images based on Yocto, or run the AGL SDK to build AGL Applications
outside of Yocto process.

## Requirements

Have a recent docker daemon (>=1.10) installed. All the setup is done inside the image so no other tool is required on the host.

## Usage

To get some help, simply run:
```
make help
```

Typically, the sequence to build an image is:

```
# make build
...
# make export
...
# make clean
```

## How it works

The Dockerfile is generic: it simply inherits from a Debian image.
When running a 'docker build':

* Docker instantiates a new container based on the latest Debian image
* Docker copies the current directory inside the container in /root/INSTALL
* then it runs the setup script /root/INSTALL/docker/setup_image.sh

In turn, this setup script will:

* source the configuration file /root/INSTALL/docker/image.conf
* execute all scripts contained in /root/INSTALL/setup.d

When the setup script finishes, Docker commits the temporary container in a new image.

This image can then be exported to a tarball and/or pushed to a Docker registry.