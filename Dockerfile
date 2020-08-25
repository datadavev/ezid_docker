FROM amazonlinux
# Base setup
RUN yum update -y
RUN yum install -y util-linux shadow-utils procps net-tools sudo yum-utils \
    tree tar git which mlocate nano curl wget httpd mariadb mariadb-devel \
    gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel \
    httpd-devel sqlite-devel bzip2-devel xz-devel libdb-devel compat-db

# Create ezid user
RUN mkdir -p /apps && useradd -ms /bin/bash -d /apps/ezid ezid \
    && echo "ezid ALL=(ALL) NOPASSWD: /bin/su - ezid, /usr/bin/yum, /usr/bin/yum-config-man" >> /etc/sudoers

# Setup ezid application folder and python virtual environment
USER ezid
WORKDIR /apps/ezid
RUN mkdir -p etc/{httpd/{conf,conf.d,conf.modules.d},init.d} var/{run,log/{httpd,ezid},www/{html,download/{public}}}; \
    ln -s /etc/httpd/modules /apps/ezid/etc/httpd/modules; \
    ln -s /apps/ezid/var/log/ezid /apps/ezid/logs; \
    echo 'export PATH="/apps/ezid/.pyenv/bin:$PATH"' >> /apps/ezid/.bash_profile; \
    echo 'eval "$(pyenv init -)"' >> /apps/ezid/.bash_profile; \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /apps/ezid/.bash_profile;
RUN curl https://pyenv.run | bash

# Create apython virtual environment called "ezid"
# It will use the version of python specified in pyver
# Note: version agnostic env name is used to avoid version name dependency in 
#       scripts that reference the python virtual environment
USER ezid
ENV pyver 2.7.18
ENV venv ezid
ENV CONFIGURE_OPTS --enable-shared
ENV CFLAGS -O2
RUN . /apps/ezid/.bash_profile; \
    pyenv install ${pyver}; \
    pyenv virtualenv ${pyver} ${venv}; \
    pyenv global ${venv}; \
    pip install --upgrade pip; \
    pip install --upgrade mod_wsgi;

# Now install the EZID application and dependencies
RUN . /apps/ezid/.bash_profile;\
    git clone https://github.com/CDLUC3/ezid.git; \
    git clone https://github.com/CDLUC3/ezid-info-pages.git ezid/templates/info; \
    cd ezid; git checkout initial-setup;

WORKDIR /apps/ezid/ezid
RUN . /apps/ezid/.bash_profile; \
    which pip ; \
    which python ; \
    pip install -r requirements.txt;

WORKDIR /apps/ezid
RUN ln -s /etc/httpd/conf/magic /apps/ezid/etc/httpd/conf/magic
ADD --chown=ezid:ezid etc/httpd/conf/httpd.conf /apps/ezid/etc/httpd/conf/
ADD --chown=ezid:ezid etc/httpd/conf.d/* /apps/ezid/etc/httpd/conf.d/
ADD --chown=ezid:ezid etc/httpd/conf.modules.d/* /apps/ezid/etc/httpd/conf.modules.d/
ADD --chown=ezid:ezid etc/init.d* /apps/ezid/etc/init.d/
ADD --chown=ezid:ezid var/www/html/robots.txt /apps/ezid/var/www/html/
ADD --chown=ezid:ezid etc/ezid_env.sh /apps/ezid/etc/ezid_env.sh

## Root account used when running the image
USER root
RUN /usr/bin/updatedb

# TODO: configure application
# TODO: verify operation