FROM kitsudo/aliyun_centos6.6
MAINTAINER Dave Luo <kitsudo163@163.com>
RUN yum install -y nginx cronolog && yum clean all
VOLUME /var/log/nginx
VOLUME /var/cache/nginx
ADD . /app/
WORKDIR /app
EXPOSE 80
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD [""]