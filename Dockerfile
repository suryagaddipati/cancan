FROM 	centos:6.4
MAINTAINER 	brettk
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum install -y npm make g++ git glibc-static java-1.6.0-openjdk.x86_64 google-chrome gcc gcc-c++ make zlib-devel openssl-devel curl-devel ncurses-devel gdbm-devel readline-devel git

RUN curl http://config/package/phantomjs-1.9.2p1.tar.gz | tar -zxvf - -C /usr/local --strip-components 1;

#NODEJS
RUN yum install -y nodejs  npm memcached 

RUN yum install -y libpng-devel
ADD .ssh /root/.ssh
RUN chown root: /root/.ssh/config
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/config

RUN echo 'NETWORKING=yes' | tee /etc/sysconfig/network > /dev/null
RUN chmod a+rw /dev/shm && npm cache clear

#Set up RUNIT
RUN mkdir /packages
RUN cd /packages && wget http://smarden.org/runit/runit-2.1.1.tar.gz
RUN cd /packages && gunzip runit-2.1.1.tar && tar -xpf runit-2.1.1.tar && rm runit-2.1.1.tar
RUN ls -la /packages/
RUN cd /packages/admin/runit-2.1.1 && ./package/install
RUN runsvdir /etc/service &

ADD npm-shrinkwrap.json /var/www/myprofile/npm-shrinkwrap.json
ADD package.json /var/www/myprofile/package.json
ADD . /var/www/myprofile/
RUN cd /var/www/myprofile && rm -rf node_modules && npm install --registry=http://npm-registry.snc1
ADD scripts/run /etc/sv/myprofile/run
ADD scripts/log /etc/sv/myprofile/log/run
RUN mkdir /etc/service
RUN ln -s /etc/sv/myprofile /etc/service
RUN mkdir /var/log/myprofile

EXPOSE 	8000
ENV NODE_ENV production
ENV APP_CONFIG_LOCAL /var/www/myprofile/config.json

CMD /usr/local/bin/runsvdir /etc/service
