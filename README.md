###Jenkins with Docker-in-Docker
The **Jenkins-with-Docker-in-Docker** container image is a standardized continuous integration
environment with both Jenkins and Docker-in-Docker. This means it had all the benefits of an easily
transportable docker container, plus it then has built in capability to build docker containers
from within. It also features CNTLM as a local proxy that can be enabled and configured via the use
of environment variables passed in at runtime, this means you can grabs things directly from your
local network (with NoProxy) and then also go out to your network proxy for anything else.


####Usage
You can build the image with a docker build command, such as:

```
docker build --rm=true -t your-registry/jenkins:latest
```

After you have a completed docker image, you can then run with the container with the following run
command: (config in square brackets is optional)

```
sudo docker run -d --name=jenkins --privileged -v /opt/jenkins:/var/jenkins_home \
  [-e DOCKER_OPTS="--dns x.x.x.x"] [-e HTTP_PROXY="x.x.x.x" -e HTTP_PROXY_PORT="xxxx"] \
  [-e NO_PROXY_LIST="localhost, 127.0.0.*, foo.bar, bar.foo"] -p 80:8080 your-registry/jenkins:latest
```

Note. the `/var/jenkins_home` volume mount is required for persistant
configuration/projects/builds/modules.


####Requirements
Unable the pinpoint the exact version, however, the use of docker-in-docker has been known to crash
with older host kernels, try to use something newer, such as 3.16+
