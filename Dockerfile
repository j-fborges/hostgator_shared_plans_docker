# Dockerfile
FROM centos:7

# ===== Build arguments (to be passed from docker-compose) =====
ARG APP_ROOT= /your/root
ARG RAILS_PROJECTS_FOLDER=/your_app

# Export as environment variables for runtime
ENV APP_ROOT=${APP_ROOT}
ENV RAILS_PROJECTS_FOLDER=${RAILS_PROJECTS_FOLDER}
ENV FULL_APP_PATH=${APP_ROOT}${RAILS_PROJECTS_FOLDER}

LABEL description="HostGator Matching Development Environment (Ruby 2.4.10)"
LABEL maintainer="Your Name"

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker

# Fix all CentOS 7 base repos (use vault.centos.org)
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install base packages and build tools
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y \
        curl wget git zip unzip tar which file procps \
        openssh-clients nc net-tools \
        make gcc gcc-c++ automake \
        openssl-devel libxml2-devel libxslt-devel \
        readline-devel sqlite-devel libcurl-devel \
        libpng-devel libjpeg-turbo-devel freetype-devel \
        zlib-devel \
        bzip2 gdbm-devel libffi-devel \
        && yum clean all

# Install MySQL 5.7 client and libraries
RUN yum install -y https://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm && \
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 && \
    yum install -y \
        mysql-community-client-5.7.44-1.el7.x86_64 \
        mysql-community-devel-5.7.44-1.el7.x86_64 \
        mysql-community-libs-5.7.44-1.el7.x86_64 \
        && yum clean all

# Install OpenSSL 1.0.2k
RUN yum install -y openssl-1.0.2k-26.el7_9.x86_64 openssl-devel-1.0.2k-26.el7_9.x86_64 && \
    yum clean all

# ===== Ruby 2.4.10 compilation from source =====
WORKDIR /tmp
RUN curl -O https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.10.tar.gz && \
    tar -xzf ruby-2.4.10.tar.gz && \
    cd ruby-2.4.10 && \
    ./configure --prefix=/usr/local/ruby-2.4.10 --enable-shared && \
    make && \
    make install

# Set environment variables to use the compiled Ruby
ENV PATH=/usr/local/ruby-2.4.10/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/ruby-2.4.10/lib:$LD_LIBRARY_PATH

# Verify Ruby version
RUN ruby -v

# Update RubyGems to version 2.6.14.4
RUN gem update --system 2.6.14.4

# Install Bundler 2.3.27
RUN gem install bundler -v 2.3.27 --no-document

# Create directory structure mimicking HostGator (using dynamic APP_ROOT)
RUN mkdir -p ${APP_ROOT}/ruby/gems && \
    mkdir -p ${APP_ROOT}/.gem/ruby && \
    mkdir -p /opt/cpanel/ea-ruby24/root/usr/bin && \
    mkdir -p /opt/cpanel/ea-ruby24/root/usr/lib64 && \
    mkdir -p /opt/cpanel/ea-openssl/lib64

# Create symlinks to mimic HostGator paths
RUN ln -sf /usr/local/ruby-2.4.10/bin/ruby /opt/cpanel/ea-ruby24/root/usr/bin/ruby && \
    ln -sf /usr/local/ruby-2.4.10/lib /opt/cpanel/ea-ruby24/root/usr/lib64

# Set gem installation path
ENV GEM_HOME=${APP_ROOT}/ruby/gems
ENV BUNDLE_PATH=${APP_ROOT}/ruby/gems
ENV BUNDLE_BIN=${APP_ROOT}/ruby/gems/bin
ENV PATH=${APP_ROOT}/ruby/gems/bin:$PATH

# Set up working directory (the Rails app will be mounted here)
WORKDIR ${FULL_APP_PATH}

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose Rails default port
EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]