# Ubuntu TeamCity agent dockerfile

## Description
  This is a configuration for build TeamCity agent based on ubuntu OS and it is aimed for provided tests in the docker containers.
  I've tested it with TeamCity 8.X server (offisial image ariya/centos6-teamcity-server:latest).

## Base Docker Image
  > FROM ubuntu:14.04
  
## Image content
  * integrated docker
  * wget & git
  * tar & unzip
  * java7
  * supervisor

## Instalation
  Easy to build:
  ```
  cd /path/to/repo
  docker build -t ubuntu_teamcity_agent:latest . 
  ```
  That's all.
  When you will run new container image will get the lates version of teamcity_agent and will start it.

## Usage
  Very simple to run:
  ```
  docker run 
    -dt 
    --privileged 
    --name teamcity_agent 
    -e TEAMCITY_SERVER=http://teamcity_server:8111 
    -e TEAMCITY_AGENT_NAME=UbuntuDocker
    -p 9090:9090 ubuntu_teamcity_agent
  ```
  Very easy to attach:
  ```
  nsenter --target $(docker inspect --format "{{ .State.Pid }}" teamcity_agent) --mount --uts --ipc --net --pid
  ```

  With docker version 1.3, there is a new command docker exec, so:
  ```
  docker exec -it teamcity_agent /bin/bash
  ```
