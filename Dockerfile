FROM fedora:20

MAINTAINER Garik Khachikyan <gkhachik@redhat.com>

# environment variables defined
ENV RHQ_VERSION 4.11.0-SNAPSHOT
ENV MAVEN_MAJOR 3
ENV MAVEN_MINOR 2.1
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk
ENV MAVEN_HOME /opt/apache-maven-3.2.1
# ENV MAVEN_OPTS -Xms256M -Xmx768M -XX:PermSize=128M -XX:MaxPermSize=256M -XX:ReservedCodeCacheSize=96M

# yum install rpms
RUN yum -y install tar git wget unzip java-1.7.0-openjdk-devel postgresql-server

# download and extract maven
RUN wget -q http://www.us.apache.org/dist/maven/maven-${MAVEN_MAJOR}/${MAVEN_MAJOR}.${MAVEN_MINOR}/binaries/apache-maven-${MAVEN_MAJOR}.${MAVEN_MINOR}-bin.tar.gz -O /opt/apache-maven-${MAVEN_MAJOR}.${MAVEN_MINOR}-bin.tar.gz 2>&1 >/dev/null
RUN tar xzvf /opt/apache-maven-${MAVEN_MAJOR}.${MAVEN_MINOR}-bin.tar.gz -C /opt 2>&1 >/dev/null

# make PATH export
RUN mkdir $HOME/.m2/

# Init postgres service
RUN su -l postgres -c "/usr/bin/initdb --pgdata='/var/lib/pgsql/data' --auth='ident'" \  >> "/var/lib/pgsql/initdb.log" 2>&1 < /dev/null

# Edit postgres config 
RUN  sed -i 's/ident/trust/'  /var/lib/pgsql/data/pg_hba.conf

# Start postgres service, create rhqadmin role and rhq db
RUN \
 su -l postgres -c " pg_ctl -l server.log -w stop; pg_ctl -l server.log -w start; ";\
 createuser -h 127.0.0.1 -p 5432 -U postgres -S -D -R -w rhqadmin;\
 createdb -h 127.0.0.1 -p 5432 -U postgres -O rhqadmin rhq;\
 createdb -h 127.0.0.1 -p 5432 -U postgres -O rhqadmin rhqdev

# git clone latest rhq
RUN git clone https://github.com/rhq-project/rhq.git rhq-maven/

# add maven good configuration settings
ADD settings.xml ${HOME}/.m2/settings.xml

ENTRYPOINT \
  export PATH=${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH};\
  su -l postgres -c " pg_ctl -l server.log -w stop; pg_ctl -l server.log -w start; ";\
  cd rhq-maven/;\
  echo "$PATH";\
  mvn -Penterprise,dev -Ddbsetup -DskipTests install
#   cp modules/enterprise/server/appserver/target/rhq-server-${RHQ_VERSION}.zip /mnt/rhq/rhq-server-${RHQ_VERSION}.zip
