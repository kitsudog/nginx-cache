#!/usr/bin/env bash
mkdir -p /var/cache/nginx
mkdir -p /etc/nginx/conf.d/cache
cat >/etc/nginx/conf.d/cache.conf <<EOF
# 中国互联网络中心 1.2.4.8 210.2.4.8
# 电信 101.226.4.6
# 联通 123.125.81.6
# 阿里 223.5.5.5 223.6.6.6
# 114系列的 114.114.114.114 114.114.114.115
resolver ${DNS:-1.2.4.8} valid=3600s;
resolver_timeout 10s; # dns解析超时10s

proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=CACHE:${KEY_SIZE:-20m} inactive=1d max_size=${CACHE_SIZE:-100m};

log_format  cache_log '|\$remote_addr|\$status|\$dest_host|\$request_time|\${dest_scheme}://\${dest_host}\${url}|';
server{
  listen      ${VIRTUAL_PORT:-80};
  server_name ${VIRTUAL_HOST:-localhost};
  if (\$query_string ~* "${PARAM_URL:-url}=(https?)://([^/]+)(/?.+)") {
    set \$dest_scheme \$1;
    set \$dest_host \$2;
    set \$url \$3;
  }
  root /usr/share/nginx/html;
  include /etc/nginx/conf.d/cache/*.conf;
  location /${PATH_FETCH:-fetch} {
    access_log  /var/log/nginx/cache.log  cache_log;
    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Methods' 'get, put, post, delete, options';
    add_header 'Access-Control-Allow-Credentials' 'true';
    add_header 'Access-Control-Allow-Headers' 'authorization, origin, content-type, accept';
    proxy_pass "\${dest_scheme}://\${dest_host}\${url}";
    proxy_cache CACHE;
    proxy_cache_valid 200 304 301 302 10d; # 目标有效的话缓存10天
    proxy_cache_valid any 60s; # 目标无效的话消停60s
    proxy_redirect              off;
    proxy_cache_key             \$query_string;
    proxy_set_header Host       \$dest_host;
    proxy_set_header Referer    \$http_referer;
    proxy_set_header User-Agent \$http_user_agent;
  }
  error_page 404 /404.html;
    location = /40x.html {
  }

  error_page 500 502 503 504 /50x.html;
    location = /50x.html {
  }
}
EOF
nginx && tail -f /dev/stdout