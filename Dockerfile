# Dockerfile for ELK stack
# Elasticsearch 2.3.1, Logstash 2.3.1, Kibana 4.5.0

# Build with:
# docker build -t <repo-user>/elk .

# Run with:
# docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 5000:5000 -it --name elk <repo-user>/elk

FROM phusion/baseimage
MAINTAINER Sebastien Pujadas http://pujadas.net
ENV REFRESHED_AT 2016-04-07

###############################################################################
#                                INSTALLATION
###############################################################################

### install Elasticsearch

RUN apt-get update -qq \
 && apt-get install -qqy curl

RUN curl http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main > /etc/apt/sources.list.d/elasticsearch-2.x.list

RUN apt-get update -qq \
 && apt-get install -qqy \
		elasticsearch=2.3.1 \
		openjdk-7-jdk \
 && apt-get clean


### install Logstash

ENV LOGSTASH_HOME /opt/logstash
ENV LOGSTASH_PACKAGE logstash-2.3.1.tar.gz

RUN mkdir ${LOGSTASH_HOME} \
 && curl -O https://download.elasticsearch.org/logstash/logstash/${LOGSTASH_PACKAGE} \
 && tar xzf ${LOGSTASH_PACKAGE} -C ${LOGSTASH_HOME} --strip-components=1 \
 && rm -f ${LOGSTASH_PACKAGE} \
 && groupadd -r logstash \
 && useradd -r -s /usr/sbin/nologin -d ${LOGSTASH_HOME} -c "Logstash service user" -g logstash logstash \
 && mkdir -p /var/log/logstash /etc/logstash/conf.d \
 && chown -R logstash:logstash ${LOGSTASH_HOME} /var/log/logstash

ADD ./logstash-init /etc/init.d/logstash
RUN sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /etc/init.d/logstash \
 && chmod +x /etc/init.d/logstash


### install Kibana

ENV KIBANA_HOME /opt/kibana
ENV KIBANA_PACKAGE kibana-4.5.0-linux-x64.tar.gz

RUN mkdir ${KIBANA_HOME} \
 && curl -O https://download.elasticsearch.org/kibana/kibana/${KIBANA_PACKAGE} \
 && tar xzf ${KIBANA_PACKAGE} -C ${KIBANA_HOME} --strip-components=1 \
 && rm -f ${KIBANA_PACKAGE} \
 && groupadd -r kibana \
 && useradd -r -s /usr/sbin/nologin -d ${KIBANA_HOME} -c "Kibana service user" -g kibana kibana \
 && mkdir -p /var/log/kibana \
 && chown -R kibana:kibana ${KIBANA_HOME} /var/log/kibana

ADD ./kibana-init /etc/init.d/kibana
RUN sed -i -e 's#^KIBANA_HOME=$#KIBANA_HOME='$KIBANA_HOME'#' /etc/init.d/kibana \
 && chmod +x /etc/init.d/kibana


###############################################################################
#                               CONFIGURATION
###############################################################################

### configure Elasticsearch

ADD ./elasticsearch.yml /etc/elasticsearch/elasticsearch.yml


### configure Logstash

# filters
ADD ./beats-input.conf /etc/logstash/conf.d/beats-input.conf
ADD ./output.conf /etc/logstash/conf.d/output.conf


###############################################################################
#                                   START
###############################################################################

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5601 9200 9300 5000 5044
VOLUME /var/lib/elasticsearch

CMD [ "/usr/local/bin/start.sh" ]
