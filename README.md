docker-base
===========

Our docker base image

## Introduction
A basic ubuntu 12.04 image which should be docker compliant. The init system is completly changed and none docker
compliant things are fixed.

This reposistory is a modified version of [m1n0/baseimage-docker](https://github.com/m1no/baseimage-docker/tree/12.04).
Insecure keys have been replaced. For further internal details please have a look at the link.

### Building
```sh
./build.sh
```
### Usage
Run the container and drop you to a shell:
```sh
docker run \
  --rm \
  -t \
  -i \
  -h mytest \
  ocedo/base:12.04 \
  /sbin/my_init -- /bin/bash -l
```
The container will be automatically removed `--rm` after you leave the shell.

### Special environment variables
With these additional environment variables declared (`docker run -e`) the
image will behave differently.

* Use `DATADOG_API_KEY` with a valid [DataDog](http://www.datadoghq.com) API key
from the integrations page. The preinstalled monitoring agent inside the
container will be started. With the additional variable `DATADOG_TAGS` you can
provide host tags (ex.: cluster,cc). The hostname provided by `-h | --hostname`
will be used as the reported hostname.


## General docker remarks
```
Words
  image         A image can consist of other images and is immutable after build
  container     Consists of the image, a virtual filesystem which holds all the changes
                against an image since runtime, a unique id, networking configuration
                and resource limits

docker build <options> <dir_of_Dockerfile>
  -t            Repository name (and optionally a tag) to be applied to the resulting image in case of success
  --no-cache    Do not use cache when building the image

docker run <options> <container_name>
  -d            Detached mode: Run container in the background, print new container id
  -e            Set environment variables
  --env-file    Read in a line delimited file of ENV variables
  --rm          Automatically remove the container when it exits (incompatible with -d)
  -t            Allocate a pseudo-tty
  -i            Keep stdin open even if not attached
  --name        Assign a name to the container
  -h            Hostname of the system (/etc/hostname)
  -P            Publish all exposed ports to the host interfaces
  -p            Publish a container's port to the host
                format: ip:hostPort:containerPort | ip::containerPort | hostPort:containerPort
  -v            Bind mount a volume (e.g., from the host: -v /host:/container, from docker: -v /container)

Remove all docker containers:
  docker rm $(docker ps -a -q)

Remove all untagged images:
  docker rmi $(docker images | grep "^<none>" | awk "{print $3}")

Remove all docker leave images:
  docker images --filter "dangling=true" |grep \<none\>|awk '{print $3}' | xargs docker rmi

Export a docker image to a file (preserve history):
  docker save <IMAGE NAME> > /home/save.tar

Import a docker image from a file (history restore):
  docker load < /home/save.tar

Export a docker container to a file (no history):  
  docker export <CONTAINER ID> > /home/export.tar

Import a docker container to a file (no history):  
  cat /home/export.tar | docker import - some-name:latest

```
Full documentation of all commands and options are available [here](https://docs.docker.com/reference/commandline/cli/#option-types)
