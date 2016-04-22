# Dockerfile to run Filebeat that listens on a tmp folder for logs
# Filebeat 1.2.1

# Build with:
# docker build -t <repo-user>/filebeat .

# Run with:
# docker run -it --link <elk-container-name>:elk \
# 	-v /tmp/filebeat_listener:/tmp/filebeat_listener <repo-user>/filebeat

FROM debian:jessie
# Based on: github.com/spujadas/elk-docker
MAINTAINER Cesar Rodriguez (cesar0094)

###############################################################################
#                                INSTALLATION
###############################################################################

### install Filebeat

RUN apt-get update -qq \
 && apt-get install -qqy curl ca-certificates \
 && apt-get clean

RUN curl -L -O https://download.elastic.co/beats/filebeat/filebeat_1.2.1_amd64.deb \
 && dpkg -i filebeat_1.2.1_amd64.deb \
 && rm filebeat_1.2.1_amd64.deb


###############################################################################
#                                CONFIGURATION
###############################################################################

### configure Filebeat

# config file
ADD filebeat.yml /etc/filebeat/filebeat.yml

# CA cert
RUN mkdir -p /etc/pki/tls/certs
ADD logstash-beats.crt /etc/pki/tls/certs/logstash-beats.crt

###############################################################################
#                                    START
###############################################################################

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD [ "/usr/local/bin/start.sh" ]
