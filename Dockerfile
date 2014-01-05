FROM ubuntu:12.04
MAINTAINER Amy Unruh <amy@infosleuth.net>
# Build file for setting up the GAE PHP SDK + mysql
# TODO: this will change once the linux SDK build is available.
# based on https://github.com/essa/docker-gae-python/ by Taku Nakajima <takunakajima@gmail.com> for python

ENV SDKURL http://googleappengine.googlecode.com/files/google_appengine_1.8.8.zip
ENV USER gae
ENV PASSWORD phpphp
ENV ROOTPASSWORD root-defaultpass

# Run upgrades
RUN echo deb http://us.archive.ubuntu.com/ubuntu/ precise universe multiverse >> /etc/apt/sources.list;\
  echo deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted universe >> /etc/apt/sources.list;\
  echo deb http://security.ubuntu.com/ubuntu precise-security main restricted universe >> /etc/apt/sources.list;\
  echo udev hold | dpkg --set-selections;\
  echo initscripts hold | dpkg --set-selections;\
  echo upstart hold | dpkg --set-selections;\
  apt-get update;\
  apt-get -y upgrade

# Install ssh

RUN apt-get install -y openssh-server && mkdir /var/run/sshd
RUN echo "root:${ROOTPASSWORD}" |chpasswd

# Install Additional packages and dependencies

RUN apt-get install -y sudo lv w3m wget curl zip zsh git vim build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev  libfontconfig1

# Install popular python packages

RUN apt-get install -y python2.7 python-pyquery python-nose python-webtest python-pip python-docutils python-software-properties

# for the php runtime
# install a build of php54, not php53
RUN add-apt-repository ppa:ondrej/php5-oldstable; apt-get update
RUN apt-get install -y php5-cgi

# TODO: not sure these next two lines are necessary.
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl
RUN apt-get install -y mysql-server
RUN apt-get install -y php5-mysql

EXPOSE 3306
# TODO: is there a way to start up mysqld automatically? Can't use multiple CMDs (apparently)
# CMD /usr/bin/mysqld_safe

# Install Google AppEngine for python SDK

ADD $SDKURL /tmp/gae.zip
RUN cd /usr/local && unzip /tmp/gae.zip
RUN ln -s /usr/local/google_appengine/dev_appserver.py /usr/local/bin && ln -s /usr/local/google_appengine/appcfg.py /usr/local/bin

# Add user

RUN useradd $USER && adduser $USER sudo && echo "${USER}:${PASSWORD}" |chpasswd && mkdir /home/$USER && chown -R $USER /home/$USER && chsh -s /bin/bash $USER

EXPOSE 22
CMD    /usr/sbin/sshd -D

