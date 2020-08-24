FROM amazonlinux
# Base setup
RUN yum update -y
RUN yum install -y util-linux shadow-utils procps net-tools sudo yum-utils \
    tar git which mlocate nano httpd mariadb MySQL-python python2-pip \
    gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel \
    sqlite-devel bzip2-devel xz-devel libdb-devel compat-db

# Create ezid user
RUN mkdir -p /apps && useradd -ms /bin/bash -d /apps/ezid ezid \
    && echo "ezid ALL=(ALL) NOPASSWD: /bin/su - ezid, /usr/bin/yum, /usr/bin/yum-config-man" >> /etc/sudoers

# Setup ezid application folder and python virtual environment
USER ezid
WORKDIR /apps/ezid
RUN mkdir -p etc/{httpd,init.d} var/{log,run}; \
    ln -s /etc/httpd/modules /apps/ezid/etc/httpd/modules; \
    echo 'export PATH="/apps/ezid/.pyenv/bin:$PATH"' >> /apps/ezid/.bash_profile; \
    echo 'eval "$(pyenv init -)"' >> /apps/ezid/.bash_profile; \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /apps/ezid/.bash_profile;
RUN curl https://pyenv.run | bash

USER ezid
ENV pyver 2.7.18
ENV venv ezid_${pyver}
ENV CONFIGURE_OPTS --enable-shared
ENV CFLAGS -O2
RUN . /apps/ezid/.bash_profile; \
    pyenv install ${pyver}; \
    pyenv virtualenv ${pyver} ${venv}; \
    pyenv global ${venv}; \
    pip install --upgrade pip;

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

# Root account used when running the image
USER root

# TODO: configure and start httpd
# TODO: configure application
# TODO: verify operation