# 部署文档

	$ uname -a
    Linux pd-dev-bvcflow-01 3.16.0-4-amd64 #1 SMP Debian 3.16.7-ckt11-1+deb8u3 ...

	sudo apt remove php5-redis
	tar xvf redis-2.2.8.tgz
	cd redis-2.2.8/
	./configure
	phpize
	make -j2
	sudo make install

    wget http://ffmpeg.org/releases/ffmpeg-3.1.4.tar.bz2
    tar xvf ffmpeg-3.1.4.tar.bz2
    cd ffmpeg-3.1.4
    make -j2
    sudo make install

    wget swoole-src-1.8.10-stable.tar.gz
    cd swoole
    phpize
    ./configure
    make
    sudo make install
	vim /etc/php5/cli/php.ini
	extension=swoole.so

    sudo apt install supervisor nginx php5 php5-dev redis-server php5-fpm php5-gd
    vim /etc/php5/fpm/pool.d/www.conf // pm.max_children = 20
    vim /etc/nginx/nginx.conf
    vim /etc/default/rsync
    vim /etc/rsyncd.conf
    vim /etc/rsyncd_secrets
    chmod o+w log/
    chmod o+w /data/vg0/ /data/vg1/

	git clone ...
    sudo apt install php5-curl
    composer.phar update
    cp -r config_sample/ config

---
 
# 其他方案

- puppet / saltstack / ansible
- virtualbox
- vagrant
- python-virtualenv
- KVM
- OpenStack

---

![][1]

##Docker - Build, Ship, and Run Any App, Anywhere
https://www.docker.com/

---

# 原理

- chroot + cgroups + namespace
- LXC 
- docker-runC

---

![][2]

---

![][3]

---

![][4]

---

# 几个核心概念
- 仓库 - repository 
- 镜像 - image
- 容器 - container

---

# Commands

# 全局

    login     Log in to a Docker registry
    logout    Log out from a Docker registry
    pull      Pull an image or a repository from a registry
    push      Push an image or a repository to a registry
    search    Search the Docker Hub for images
    volume    Manage Docker volumes
    version   Show the Docker version information
    network   Manage Docker networks
    stats     Display a live stream of container(s) resource usage statistics
    info      Display system-wide information
    events    Get real time events from the server
    inspect   Return low-level information on a container or image

# 镜像

    tag       Tag an image into a repository
    history   Show the history of an image
    rmi       Remove one or more images
    images    List images
    commit    Create a new image from a container's changes
    export    Export a container's filesystem as a tar archive
    import    Import the contents from a tarball to create a filesystem image
    save      Save one or more images to a tar archive
    load      Load an image from a tar archive or STDIN
    kill      Kill a running container
    run       Run a command in a new container

# 容器

    create    Create a new container
    attach    Attach to a running container
    cp        Copy files/folders between a container and the local filesystem
    diff      Inspect changes on a container's filesystem
    exec      Run a command in a running container
    start     Start one or more stopped containers
    stop      Stop a running container
    rm        Remove one or more containers
    logs      Fetch the logs of a container
    port      List port mappings or a specific mapping for the CONTAINER
    ps        List containers
    pause     Pause all processes within a container
    unpause   Unpause all processes within a container
    top       Display the running processes of a container
    rename    Rename a container
    restart   Restart a container
    wait      Block until a container stops, then print its exit code
    update    Update configuration of one or more containers

---

## Dockerfile

	from php:7.0.12-fpm-alpine
	run sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/' /etc/apk/repositories
	run apk update
	run apk add autoconf g++ make linux-headers bash zlib-dev ffmpeg libpng-dev openrc nginx
	run docker-php-ext-install gd && docker-php-ext-enable gd

	add . .
	run tar xvf swoole-1.8.12.tgz && cd swoole-1.8.12/ &&  phpize &&./configure && make && make install
	run docker-php-ext-enable swoole && docker-php-ext-install pdo_mysql
	run pecl install redis && docker-php-ext-enable redis
	copy ./etc_localtime /etc/localtime

- docker build . -t tangjunxing/myflask:v1
- docker create tangjunxing/myflask:v1 --name container_name
- docker start container_name
- docker ps container_name

---

## docker-compose

    docker-compose.yaml
        app:
          image: 3fcc2dbcb3dd
          build: hello-flask
          ports:
            - 5180:5180
          volumes:
            - ./v:/v
          command: python /v/a.py

- docker-compose up -d
- docker-compose ps name
- docker-compose exec name sh

# 存储

	Storage Driver: aufs
	Root Dir: /var/lib/docker/aufs
	Backing Filesystem: xfs
	Dirs: 269
	Dirperm1 Supported: true

# 为什么要分层文件系统

- pull一个ubuntu的镜像,自己安装python,flask
- pull一个python的镜像,自己安装flask
- pull一个flask的镜像,直接使用

# 网络

	$ docker network ls
	NETWORK ID          NAME                DRIVER
	c8a4f98bfc82        bridge              bridge
	175a8d2b4a66        host                host
	371bf33a9760        none                null

---

# 性能

---

ps auxf |grep -B2 php

---

	$ curl "http://127.0.0.1:7080/index.html"
	hello docker!!!

	Running 10s test @ http://127.0.0.1:7080/index.html
	  2 threads and 10 connections
	  Thread Stats   Avg      Stdev     Max   +/- Stdev
		Latency     3.12ms    5.26ms  38.12ms   84.93%
		Req/Sec    14.84k     1.95k   28.35k    72.64%
	  296712 requests in 10.10s, 71.29MB read
	Requests/sec:  29378.69
	Transfer/sec:      7.06MB

---

	curl "http://127.0.0.1:5080/index.html"
	hello nginx

	Running 10s test @ http://127.0.0.1:5080/index.html
	  2 threads and 10 connections
	  Thread Stats   Avg      Stdev     Max   +/- Stdev
		Latency     3.67ms    5.50ms  45.77ms   81.60%
		Req/Sec    19.98k     1.69k   21.98k    90.50%
	  397534 requests in 10.00s, 94.00MB read
	Requests/sec:  39746.02
	Transfer/sec:      9.40MB

# cpu

## host

	tjx $ echo "scale=5000;4*a(1)"|time bc -l -q|tail -1
	17.72user 0.00system 0:17.73elapsed 99%CPU (0avgtext+0avgdata 2032maxresident)k
	0inputs+0outputs (0major+129minor)pagefaults 0swaps
	73774418426312986080998886874132604720

## docker

	/var/www/html # echo "scale=5000;4*a(1)"|time bc -l -q|tail -1
	73774418426312986080998886874132604720
	real    0m 20.50s
	user    0m 20.49s
	sys     0m 0.00s

# disk-io

## host

	tjx $ time dd if=/dev/zero of=/tmp/test1.img bs=1G count=1 oflag=sync                                             1+0 records in                                           1+0 records out                                          1073741824 bytes (1.1 GB) copied, 9.6779 s, 111 MB/s     0.00user 1.00system 0:09.88elapsed 10%CPU (0avgtext+0avgdata 1050568maxresident)k
	0inputs+2097152outputs (0major+262227minor)pagefaults 0swaps


## docker

	/var/www/html # time dd if=/dev/zero of=/tmp/test1.img bs=1G count=1 conv=sync
	1+0 records in
	0+1 records out
	real    0m 7.60s
	user    0m 0.00s
	sys     0m 0.72s


# 使用docker的两种姿势

- daemon - supervisor nginx php-fpm python-web
- cli - composer php-cli npm

---

# tips

# 非linux环境
- (win/mac)docker-toolbox - boot2docker
- (win10)docker for windows - Hyper-v
- (mac)docker for mac

# 加速 docker pull

    cat /etc/default/docker
    DOCKER_OPTS="--registry-mirror=https://enka2nxd.mirror.aliyuncs.com"

https://docs.docker.com/engine/admin/systemd/#http-proxy

sudo systemctl show --property=Environment docker
sudo systemctl daemon-reload
systemctl show --property=Environment docker
sudo systemctl restart docker


# Alpine

	tjx $ sudo docker images|grep nginx
	nginx :alpine 4.21 MB
	nginx 	      190.5 MB

# Shell

- ssh docker_up - 错误用法
- docker exec -ti CONTAINERID bash
- docker attach
- nsenter(docker-enter)

---

Thanks

### 参考文献

	library/scratch - Docker Hub https://hub.docker.com/_/scratch/
    http://stackoverflow.com/questions/22111060/difference-between-expose-and-publish-in-docker
    最新博客条目 - 公共博客 https://www.ibm.com/developerworks/community/blogs/roller-ui/homepage?lang=zh
    UC技术博客 | tech.uc.cn http://tech.uc.cn/
    微容器：更小的，更轻便的Docker容器 | phper http://chattool.sinaapp.com/?p=1200
	wsargent/docker-cheat-sheet: Docker Cheat Sheet https://github.com/wsargent/docker-cheat-sheet
	GitLab Container Registry | GitLab https://about.gitlab.com/2016/05/23/gitlab-container-registry/
    Alpine Linux 镜像源使用帮助 [LUG@USTC] https://lug.ustc.edu.cn/wiki/mirrors/help/alpine
	https://docs.docker.com/compose/compose-file/#net
    Docker Hub Mirror使用手册 - DockOne.io http://dockone.io/article/160
    Docker背后的内核知识——cgroups资源限制
        http://www.infoq.com/cn/articles/docker-kernel-knowledge-cgroups-resource-isolation

[1]: http://static.zybuluo.com/mrytsr/f3n2hb8lwxoatdo2al5q94c5/R351508499TJ.jpg
[2]: images/k.jpg
[3]: images/j.jpg
[4]: images/h.jpg
