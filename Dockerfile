FROM kitsudo/aliyun_centos6.6
MAINTAINER Dave Luo <kitsudo163@163.com>
RUN yum install -y nginx && yum clean all
VOLUME /var/log/nginx
ADD . /app/
WORKDIR /app

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD [""]