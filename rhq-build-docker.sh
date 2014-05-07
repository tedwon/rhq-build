#!/bin/bash
export RHQ_VERSION=4.11.0
export MAVEN_MAJOR=3
export MAVEN_MINOR=2.1
export RHQ_BRANCH=release-4.11.0

if [[ $(cat /etc/redhat-release | grep Fedora) ]]; then
  export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk
else
  export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64
fi
export MAVEN_HOME=/opt/apache-maven-3.2.1
export PATH=${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH};

# install packages needed
yum -y install tar git wget unzip openssh-clients java-1.7.0-openjdk-devel postgresql-server

# maven install
wget -q http://www.us.apache.org/dist/maven/maven-${MAVEN_MAJOR}/${MAVEN_MAJOR}.${MAVEN_MINOR}/binaries/apache-maven-${MAVEN_MAJOR}.${MAVEN_MINOR}-bin.tar.gz -O /opt/apache-maven-${MAVEN_MAJOR}.${MAVEN_MINOR}-bin.tar.gz 2>&1 >/dev/null
tar xzvf /opt/apache-maven-${MAVEN_MAJOR}.${MAVEN_MINOR}-bin.tar.gz -C /opt 2>&1 >/dev/null
mkdir /root/.m2/
curl -sSL https://raw.githubusercontent.com/gkhachik/rhq-build/master/settings.xml > /root/.m2/settings.xml
sed -i "s/<rhq.rootDir>.*<\/rhq.rootDir>/<rhq.rootDir>\/root\/rhq\/rhq-build<\/rhq.rootDir>/g" /root/.m2/settings.xml

# postgres configuration
su -l postgres -c "/usr/bin/initdb --pgdata='/var/lib/pgsql/data' --auth='ident'" \  >> "/var/lib/pgsql/initdb.log" 2>&1 < /dev/null
sed -i 's/ident/trust/'  /var/lib/pgsql/data/pg_hba.conf
su -l postgres -c " pg_ctl -l server.log -w stop; pg_ctl -l server.log -w start; ";
createuser -h 127.0.0.1 -p 5432 -U postgres -S -D -R -w rhqadmin;
createdb -h 127.0.0.1 -p 5432 -U postgres -O rhqadmin rhq;
createdb -h 127.0.0.1 -p 5432 -U postgres -O rhqadmin rhqdev

# git clone the repo
mkdir -p /root/rhq/rhq-build/
git clone -b ${RHQ_BRANCH} https://github.com/rhq-project/rhq.git /root/rhq/rhq-build
cd /root/rhq/rhq-build

# run the mvn build
mvn -Penterprise,dev -Ddbsetup -DskipTests install

