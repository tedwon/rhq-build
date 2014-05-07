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

cd /root/rhq/rhq-build
git clean -xdf
git fetch origin
git checkout ${RHQ_BRANCH}
git pull origin ${RHQ_BRANCH}

# drop DB and init it again
su -l postgres -c " pg_ctl -l server.log -w stop; pg_ctl -l server.log -w start; "
dropdb -h 127.0.0.1 -p 5432 -U postgres rhqdev
dropdb -h 127.0.0.1 -p 5432 -U postgres rhq
dropuser -h 127.0.0.1 -p 5432 -U postgres rhqadmin
createuser -h 127.0.0.1 -p 5432 -U postgres -S -D -R -w rhqadmin;
createdb -h 127.0.0.1 -p 5432 -U postgres -O rhqadmin rhq;
createdb -h 127.0.0.1 -p 5432 -U postgres -O rhqadmin rhqdev

# run the mvn build
mvn -Penterprise,dev -Ddbsetup -DskipTests install

# prepare to upload to sourceforge.com
rm -f /root/.ssh/id_dsa_rhq_sourceforge*
mkdir /root/.ssh
curl -sSL ${SSH_PRIVATE_KEY} > /root/.ssh/id_dsa_rhq_sourceforge
chmod 600 /root/.ssh/id_dsa_rhq_sourceforge

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_dsa_rhq_sourceforge gkhachik,rhqbuild@shell.sourceforge.net create

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_dsa_rhq_sourceforge gkhachik,rhqbuild@shell.sourceforge.net "mkdir -p /home/frs/project/rhqbuild/rhq/rhq-${RHQ_VERSION}"
rsync -aiv -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_dsa_rhq_sourceforge" /root/rhq/rhq-build/modules/enterprise/server/appserver/target/rhq-server-${RHQ_VERSION}.zip gkhachik,rhqbuild@shell.sourceforge.net:/home/frs/project/rhqbuild/rhq/rhq-${RHQ_VERSION}/
