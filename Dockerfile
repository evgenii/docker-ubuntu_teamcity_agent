################################################################
# Dockerfile to install:
#   * git
#   * docker
#   * java7
#   * teamcity_agent
#   * Supervisor
# Ver 0.0.4
#
# docker build -t ubuntu_teamcity_agent:v4 .
# run daemon: docker run --privileged --name teamcity_agent -e TEAMCITY_SERVER=http://teamcity_server:8111 -dt -p 9090:9090 ubuntu_teamcity_agent
# run shell:  docker run --privileged --name teamcity_agent_cmd -e TEAMCITY_SERVER=http://teamcity_server:8111 --rm -it ubuntu_teamcity_agent /bin/bash
# connect to runung container: nsenter --target $PID --mount --uts --ipc --net --pid
#
FROM ubuntu:14.04
MAINTAINER evgenii.s.semenchuk <evgenii.s.semenchuk@gmail.com>

# Install docker
ADD https://get.docker.io/builds/Linux/x86_64/docker-latest /usr/local/bin/docker
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list && \
    apt-get update -qq && apt-get install -qqy iptables ca-certificates lxc && apt-get clean && \
    chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker
VOLUME /var/lib/docker

# Install java7
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -y install wget tar unzip && \
    apt-get install -y software-properties-common python-software-properties && \
    apt-add-repository -y ppa:webupd8team/java && \
    apt-get -y update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java7-installer

# Install teamcity-agent
ENV TEAMCITY_SERVER http://172.17.42.1:8111
ENV TEAMCITY_AGENT_NAME UbuntuDocker
RUN mkdir -p /home/teamcity && \
    useradd teamcity -d /home/teamcity && \
    chown teamcity:teamcity /home/teamcity
ADD ./setup-agent.sh /home/teamcity/setup-agent.sh
EXPOSE 9090

# Install git
RUN apt-get install -y git-core && apt-get clean

# Install & configure Supervisor
RUN apt-get -y install supervisor && \
    mkdir -p /var/log/supervisor
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Run Supervisor
CMD ["/usr/bin/supervisord"]
