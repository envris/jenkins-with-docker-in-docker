FROM ubuntu:utopic

MAINTAINER Aaron Nicoli <aaronnicoli@gmail.com>


RUN echo "1.565.1" > .lts-version-number

RUN apt-get update && apt-get install -y wget git curl zip
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-7-jdk
RUN apt-get update && apt-get install -y maven ant ruby rbenv make


# Install Docker from Docker Inc. repositories.
RUN apt-get update && apt-get install -y apt-transport-https iptables ca-certificates lxc git
RUN echo "deb https://get.docker.io/ubuntu docker main" >> /etc/apt/sources.list.d/docker.list
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A88D21E9 && \
    gpg --armor --export A88D21E9 | apt-key add -

VOLUME ["/var/lib/docker"]

RUN apt-get update && apt-get install -y lxc-docker

RUN rm -f /etc/default/docker


RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
RUN echo deb http://pkg.jenkins-ci.org/debian-stable binary/ >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y jenkins
RUN mkdir -p /var/jenkins_home && chown -R jenkins /var/jenkins_home
ADD init.groovy /tmp/WEB-INF/init.groovy
RUN cd /tmp && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy
ADD ./jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod +x /usr/local/bin/jenkins.sh

RUN apt-get install -y cntlm
ADD ./cntlm.conf /etc/cntlm.conf
RUN chown cntlm:root /etc/cntlm.conf && chmod 600 /etc/cntlm.conf

USER jenkins

# VOLUME /var/jenkins_home - bind this in via -v if you want to make this persistent.
ENV JENKINS_HOME /var/jenkins_home

# define url prefix for running jenkins behind Apache (https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache)
ENV JENKINS_PREFIX /

USER root
WORKDIR /

# for main web interface:
EXPOSE 8080 

# will be used by attached slave agents:
EXPOSE 50000 

CMD ["/usr/local/bin/jenkins.sh"]
