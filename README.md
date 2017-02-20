# nginx-cache
一个简单的服务器当做缓存代理访问(GET)资源的nginx配置
主要是为了可以跨域访问图片资源啥的

docker run -d \
--restart=always \
-e VIRTUAL_HOST=www.cache.com \
-e VIRTUAL_PORT=80 \
-e PATH_FETCH=fetch \ 
-e PARAM_URL=url \
-e KEY_SIZE=20m \
-e CACHE_SIZE=100m \
-v /path/custom/:/var/nginx/conf.d/cache/ \
daocloud.io/kitsudo/nginx-cache

如此构造的请求为
`http://www.cache.com:80/fetch?url=https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_fe6da1ec.png`

### 个性化的请求定制

内有几个变量(例子: `https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_fe6da1ec.png`)
* `$dest_scheme` => `https`
* `$dest_host` => `ss0.bdstatic.com`
* `$url` => `/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_fe6da1ec.png`

最终转发的地址为
`${dest_scheme}://${dest_host}${url}`

例子
```
if ($query_string ~* "url=http://q.qlogo.cn(/.+).jpg$") {
   set $url $1;
}
```


