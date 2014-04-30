FROM fedora:20

MAINTAINER Garik Khachikyan <gkhachik@redhat.com>

ADD rhq-build-docker.sh /usr/local/bin/rhq-build-docker.sh
ADD rhq-push.sh /usr/local/bin/rhq-push.sh

RUN /usr/local/bin/rhq-build-docker.sh

ENTRYPOINT ["/usr/local/bin/rhq-push.sh"]
