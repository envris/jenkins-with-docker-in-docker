#!/bin/bash

# Setup CNTLM no proxy
if [ "${HTTP_PROXY}" != "" ] && [ "${HTTP_PROXY_PROXY}" != "" ] ; then
  CNTLM_CONFIG=$(cat /etc/cntlm.conf | grep ${HTTP_PROXY});
  if [ "${CNTLM_CONFIG}" == "" ] ; then
    sed -i "s;^Proxy .*;Proxy ${HTTP_PROXY}:${HTTP_PROXY_PROXY};" /etc/cntlm.conf
    sed -i "s;^NoProxy .*;NoProxy ${NO_PROXY_LIST};" /etc/cntlm.conf
  fi
  # Start CNTLM
  /etc/init.d/cntlm start
  sleep 1s
fi

# Setup docker opts
DOCKER_DEFAULT=$(cat /etc/default/docker | grep DOCKER_OPTS);
if [ "${DOCKER_DEFAULT}" == "" ] ; then
  echo "DOCKER_OPTS=\"${DOCKER_OPTS}\"" >> /etc/default/docker
fi

# Start docker
/etc/init.d/docker start

sleep 6s

# Start jenkins
if [ "${HTTP_PROXY}" != "" ] && [ "${HTTP_PROXY_PROXY}" != "" ] ; then
  exec java -Dorg.apache.commons.jelly.tags.fmt.timeZone=Australia/Sydney -DhttpProxyHost=${HTTP_PROXY} -DhttpProxyPort=${HTTP_PROXY_PROXY} -DhttpsProxyHost=${HTTP_PROXY} -DhttpProxyPort=${HTTP_PROXY_PROXY} -jar /usr/share/jenkins/jenkins.war --prefix=$JENKINS_PREFIX
else
  exec java -Dorg.apache.commons.jelly.tags.fmt.timeZone=Australia/Sydney -jar /usr/share/jenkins/jenkins.war --prefix=$JENKINS_PREFIX
fi
