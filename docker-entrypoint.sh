#!/usr/bin/env bash
mkdir -p /var/cache/nginx
cat >/etc/nginx/conf.d/cache.conf <<EOF
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=IMAGE:20m inactive=1d max_size=100m;
log_format  cache_log '|\$remote_addr|\$status|\$dest_host|\$request_time|\${dest_scheme}://\${dest_host}\${url}|';
server{
  listen      ${VIRTUAL_PORT:-80}
  server_name ${VIRTUAL_HOST:-_};
  if (\$query_string ~* "${PARAM_URL:-url}=(https?)://([^/]+)(/?.+)") {
    set \$dest_scheme \$1;
    set \$dest_host \$2;
    set \$url \$3;
  }
  include /etc/nginx/conf.d/cache_*.conf;
  location /${PATH_FETCH} {
    access_log  /var/log/nginx/cache.log  cache_log;
    add_header Access-Control-Allow-Origin *;
    resolver   114.114.114.114;
    proxy_pass "\${dest_scheme}://\${dest_host}\${url}";
    proxy_cache IMAGE;
    proxy_cache_valid  200 304 301 302 10d;
    proxy_cache_valid  any 1d;
    proxy_cache_key \$query_string;
    proxy_redirect                      off;
    proxy_set_header   Host             \$dest_host;
  }
}
EOF
nginx