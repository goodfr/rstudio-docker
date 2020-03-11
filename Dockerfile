FROM rocker/tidyverse:3.6.2

USER root

# some comment for autobuild t2

# Spark dependencies versions
# ENV APACHE_SPARK_VERSION 2.1.0
# ENV HADOOP_VERSION 2.7

# Quick fix from SO : https://stackoverflow.com/questions/32942023/ubuntu-openjdk-8-unable-to-locate-package
# for openjdk-8-jdk
# RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
# RUN apt-get -y install python-software-properties
RUN apt-get -y install --fix-missing software-properties-common
# RUN add-apt-repository ppa:webupd8team/java && apt-get install -y oracle-java8-installer
# RUN apt-get install -y openjdk-8-jdk

# curtesy of https://github.com/gadenbuie/docker-tidyverse-rjava/blob/master/Dockerfile
RUN apt-get -y update && apt-get install -y \
   default-jdk \
   r-cran-rjava \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/

# Install system libraries required by R packages # openjdk-8-jdk before systemd
RUN apt-get -y update  && apt-get install -y libcups2 libcups2-dev systemd \
    unixodbc-dev libbz2-dev libgsl-dev odbcinst libx11-dev mesa-common-dev libglu1-mesa-dev \
    gdal-bin proj-bin libgdal-dev libproj-dev libudunits2-dev libtcl8.6 libtk8.6 libgtk2.0-dev && \
    apt-get clean

# Install Impala ODBC dependency
RUN cd /tmp && \
    wget --no-verbose https://downloads.cloudera.com/connectors/impala_odbc_2.5.41.1029/Debian/clouderaimpalaodbc_2.5.41.1029-2_amd64.deb && \
    dpkg -i clouderaimpalaodbc_2.5.41.1029-2_amd64.deb && \
    odbcinst -i -d -f /opt/cloudera/impalaodbc/Setup/odbcinst.ini

# Install Spark
# RUN cd /tmp && \
#     wget -q https://archive.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
#     tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local && \
#     rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

# Mesos dependencies
# RUN DISTRO=debian && \
#     CODENAME=stretch && \
#     echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" > /etc/apt/sources.list.d/mesosphere.list && \
#     apt-get -y update && \
#     apt-get --no-install-recommends -y --force-yes install mesos=1.3.1-2.0.1 && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# # Spark and Mesos config
# ENV SPARK_HOME /usr/local/spark
# ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
# ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

# RUN R -e "install.packages('sparklyr', repos='http://cran.rstudio.com/', dependencies=T)"

# # Install Saagie's RStudio Addin
# RUN R -e "install.packages('devtools')" && \
#   R -e "devtools::install_github('saagie/rstudio-saagie-addin')"

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Install R packages
RUN R CMD javareconf && R -e "install.packages('rJava')" && \
R -e "install.packages('DBI')" && \
 R -e "install.packages('odbc')" && \
 R -e "install.packages('h2o')" && \
 R -e "install.packages('ROCR')" && \
 R -e "install.packages('corrplot')" && \
 R -e "install.packages('dummies')" && \
 R -e "install.packages('xgboost')" && \
 R -e "install.packages('plotly')" && \
 R -e "install.packages('doParallel')" && \
 R -e "install.packages('jsonlite')" && \
 R -e "install.packages('forecast')" && \
 R -e "install.packages('tseries')" && \
 R -e "install.packages('trend')" && \
 R -e "install.packages('rvest')" && \
 R -e "install.packages('curl')" && \
 R -e "install.packages('Rcpp')" && \
 R -e "install.packages('ggplot2')" && \
 R -e "install.packages('rpart.plot')" && \
 R -e "install.packages('reshape2')" && \
 R -e "install.packages('shiny')" && \
 R -e "install.packages('markdown')" && \
 R -e "install.packages('shinydashboard')" && \
 R -e "install.packages('knitr')" && \
 R -e "install.packages('shinyjs')" && \
 R -e "install.packages('shinythemes')" && \
 R -e "install.packages('dtplyr')" && \
 R -e "install.packages('stringr')" && \
 R -e "install.packages('data.table')" && \
 R -e "install.packages('xlsx')" && \
 R -e "install.packages('readxl')" && \
 R -e "install.packages('readr')" && \
 R -e "install.packages('leaflet')" && \
 R -e "install.packages('RColorBrewer')" && \
 R -e "install.packages('colourpicker')" && \
 R -e "install.packages('scales')" && \
 R -e "install.packages('FactoMineR')" && \
 R -e "install.packages('kernlab')" && \
 R -e "install.packages('rpart')" && \
 R -e "install.packages('e1071')" && \
 R -e "install.packages('randomForest')" && \
 R -e "install.packages('pls')" && \
 R -e "install.packages('betareg')" && \
 R -e "install.packages('glmnet')" && \
 R -e "install.packages('leaps')" && \
 R -e "install.packages('mlogit')" && \
 R -e "install.packages('pROC')" && \
 R -e "install.packages('caret')" && \
 R -e "install.packages('stringi')" && \
 R -e "install.packages('SnowballC')" && \
 R -e "install.packages('magrittr')" && \
 R -e "install.packages('doSNOW')"

RUN mkdir /root/.R/
RUN echo CXXFLAGS=-DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION > /root/.R/Makevars
RUN R -e "install.packages('prophet')"

# Be sure rstudio user has full access to his home directory
RUN mkdir -p /home/rstudio && \
  chown -R rstudio:rstudio /home/rstudio && \
  chmod -R 755 /home/rstudio

ADD ./init_rstudio.sh /
RUN chmod 500 /init_rstudio.sh

# JAVA_HOME define
ENV PATH=$JAVA_HOME/bin:$PATH

# Hadoop client installation
RUN wget --no-verbose http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.6.0-cdh5.7.1.tar.gz \
&& tar -xzf hadoop-2.6.0-cdh5.7.1.tar.gz \
&& rm hadoop-2.6.0-cdh5.7.1.tar.gz \
&& mv hadoop-2.6.0-cdh5.7.1 /usr/local/hadoop
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin

# Hive client installation
RUN wget --no-verbose http://apache.mirrors.ovh.net/ftp.apache.org/dist/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz \
&& tar -xvzf apache-hive-1.2.2-bin.tar.gz \
&& rm apache-hive-1.2.2-bin.tar.gz \
&& cd apache-hive-1.2.2-bin
ENV HIVE_HOME=/apache-hive-1.2.2-bin
ENV PATH=$HIVE_HOME/bin:$PATH

RUN R -e "install.packages('getPass')"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      krb5-user && \
    rm -rf /var/lib/apt/lists/*;

# Install Hive ODBC driver
RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      libsasl2-modules-gssapi-mit && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
    wget --no-verbose https://downloads.cloudera.com/connectors/ClouderaHive_ODBC_2.6.4.1004/Debian/clouderahiveodbc_2.6.4.1004-2_amd64.deb && \
    dpkg -i clouderahiveodbc_2.6.4.1004-2_amd64.deb && \
    odbcinst -i -d -f /opt/cloudera/hiveodbc/Setup/odbcinst.ini && \
    rm /tmp/clouderahiveodbc_2.6.4.1004-2_amd64.deb

# Store Root envvar to be able to exclude it at runtime when propagating envvars to every user
RUN env >> /ROOT_ENV_VAR && chmod 400 /ROOT_ENV_VAR

CMD ["/bin/sh", "-c", "/init_rstudio.sh"]
