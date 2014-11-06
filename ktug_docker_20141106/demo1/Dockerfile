FROM fedora:rawhide

RUN yum -y update && yum -y install vim

VOLUME /log

COPY app.sh app.sh

ENTRYPOINT ["./app.sh"]
