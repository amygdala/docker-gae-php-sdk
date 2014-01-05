docker-gae-php-sdk
==================

A GAE PHP SDK docker build file.  Still tuning.

To run (on GCE):

From [http://docs.docker.io/en/latest/installation/google/](http://docs.docker.io/en/latest/installation/google/):

    gcutil addinstance docker-playground --image=backports-debian-7
    gcutil ssh docker-playground

Then:

    echo net.ipv4.ip_forward=1 | sudo tee /etc/sysctl.d/99-docker.conf
    sudo sysctl --system
    curl get.docker.io | bash
    sudo update-rc.d docker defaults

Also from the [docs](http://docs.docker.io/en/latest/installation/google/):
"If running in zones: us-central1-a, europe-west1-1, and europe-west1-b, the docker daemon must be started with the -mtu flag. Without the flag, you may experience intermittent network pauses. See [this issue](https://code.google.com/p/google-compute-engine/issues/detail?id=57) for more details."

    docker -d -mtu 1460

Next:

    git clone https://github.com/amygdala/docker-gae-php-sdk.git

Then (drawing from [https://github.com/essa/docker-gae-python](https://github.com/essa/docker-gae-python)):

    cd docker-gae-php-sdk
    docker build -t gae-php .
    sudo docker run -d -p 3306:3306 -p 2022:22 -p 8080:8080 -v /path/to/docker-gae-php-sdk/home:/home/gae:rw gae-php

`docker-gae-php-sdk/home` is mapped to the home directory of the Docker container.

    ssh gae@localhost -p 2022  # the given Dockerfile sets password as `phpphp`.
    # start the mysql server after you start the container
    /usr/bin/mysqld_safe &

then:

    /usr/local/google_appengine/dev_appserver.py /usr/local/google_appengine/demos/php/guestbook/ --port 8080 --host 0.0.0.0

or e.g. you can start the container like this:

	sudo docker run -t -i -p 8080:8080 -p 3306:3306 -v /path/to/docker-gae-php-sdk/home:/home/gae:rw gae-php bash

Open port 8080 in the firewall for your GCE instance if you like.










