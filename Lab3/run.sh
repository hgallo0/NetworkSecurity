#/bin/bash

apt-get update
apt-get install docker.io -y

service docker start 

docker stop mysql ; docker rm mysql
docker stop site; docker rm site
docker run -dt \
--name mysql \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=test \
-e MYSQL_USER=hgallo mysql

docker run -dt \
--name site \
-p 80:80 \
-v $(pwd)/config:/usr/local/etc/php \
-v $(pwd)/html:/var/www/html \
--link mysql \
hgallo/http-php:01
