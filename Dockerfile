FROM kitsudo/aliyun_centos6.6
MAINTAINER Dave Luo <kitsudo163@163.com>
RUN yum install -y nginx
ADD . /app/
WORKDIR /app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [""]