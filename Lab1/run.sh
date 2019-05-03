#/bin/bash

echo " .----------------.  .----------------.  .----------------.   .----------------. "
echo "| .--------------. || .--------------. || .--------------. | | .--------------. |"
echo "| |   _____      | || |      __      | || |   ______     | | | |     __       | |"
echo "| |  |_   _|     | || |     /  \     | || |  |_   _ \    | | | |    /  |      | |"
echo "| |    | |       | || |    / /\ \    | || |    | |_) |   | | | |    \`| |      | |"
echo "| |    | |   _   | || |   / ____ \   | || |    |  __'.   | | | |     | |      | |"
echo "| |   _| |__/ |  | || | _/ /    \ \_ | || |   _| |__) |  | | | |    _| |_     | |"
echo "| |  |________|  | || ||____|  |____|| || |  |_______/   | | | |   |_____|    | |"
echo "| |              | || |              | || |              | | | |              | |"
echo "| '--------------' || '--------------' || '--------------' | | '--------------' |"
echo " '----------------'  '----------------'  '----------------'   '----------------' "

# verify if docker is installed

echo "checking docker package"
which docker  2>&1 >/dev/null
[ $? -ne 0 ] && apt-get update && \
apt-get install docker.io -y

echo "checking docker service"
docker ps 2>&1 >/dev/null
[ $? -ne 0 ] && \
service docker start 

echo "Cleaning env"
docker stop mysql 2>&1 >/dev/null ; docker rm mysql 2>&1 >/dev/null
docker stop site 2>&1 >/dev/null; docker rm site 2>&1 >/dev/null

docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 network-lab

echo "starting mysql"
docker run -dt \
--name mysql \
-p 3306:3306 \
--network=network-lab \
-e MYSQL_ROOT_PASSWORD=test \
-e MYSQL_USER=hgallo mysql

echo "starting apache"
docker run -dt \
--name site \
-p 80:80 \
--network=network-lab \
-v $(pwd)/config:/usr/local/etc/php \
-v $(pwd)/html:/var/www/html \
hgallo/http-php:01

sqlloader(){
  docker exec -i mysql mysql -uroot -ptest < config/data 
  [ $? -eq 0 ] && echo "Data loaded successfully!"
  exit 0
}

echo "starting readines probe"
readines() {
  output=1
  i=0
  printf "["
  while [ $output -ne 0 ]; do
      docker exec -it mysql mysql -uroot -ptest -e 'show databases;' 2>&1 >/dev/null
    [ $? -eq 0 ] && sqlloader 2>/dev/null
    [ $i -eq 24 ] && exit 1
    (( i++ ))
    sleep 1
    echo -ne $iecho -ne "-"
  done
  printf "] TIMED OUT \n"
}

readines
