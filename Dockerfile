# vergunt (Vim, Elixir, Ruby, Go, Git, Ubuntu, NodeJS, and TMux)
#
# VERSION 1.3.0
#
# Build image example:
#   docker build -t hogihung/vergunt:1.3.0 .
#
# This Dockerfile is used to build a base development environment with vim, go,
# elixir, ruby, git, tmux, and node js all running on Ubuntu 18.10 base image.
#
# Using the Ubuntu Linux 18.10 image, we will add the following:
#   vim, rvm, kiex, ruby, elixir (with erlang), go, git, node and tmux.
#
# At the time of this creation, we have the following versions:
#   RVM => 1.29.4, Vim => 8.1, Ruby => (2.5.3, 2.4.1, 1.3.5),
#   Elixir => 1.7.3, Git => 2.19.1, Go => 1.11.1, Node => 10.12.0,
#   Ubuntu => 18.10, TMux => 2.7
#
# This image now has the customized Vim built-in instead of manually adding
# afterwards.
#
# Running a container example:
#   docker run -it --name=vergun --hostname=ruby-dev --rm [image-id-here]
#   **Note: the --rm flag is optional.  It will remove the container on exit.
# -------------------------------------------------------------------
FROM ubuntu:18.10
MAINTAINER John F. Hogarty <hogihung@gmail.com>

# Create the development and directores for cloudmeta-server
RUN mkdir -p /usr/local/development

# Change our working directory
WORKDIR /usr/local/development

# Update and install all of the required packages.
RUN apt-get update -y && \
    apt-get install -y curl htop tar tree wget && \
    apt-get install -y software-properties-common

# Update Ubuntu, Install Vim, Tmux and Git
RUN add-apt-repository -y ppa:jonathonf/vim && \
    apt-get update -y && \
    apt-get install -y vim tmux git-core

# Install Git 2.7.x
RUN apt-get update -y && \
    apt install -y git-core

# Prerequisites for Elixir/Erlang Install
RUN apt-get install -y build-essential git wget libssl-dev libreadline-dev \
    libncurses5 libncurses5-dev zlib1g-dev m4 curl wx-common libwxgtk3.0-dev \
    libsctp1 autoconf

# Install Erlang (required for Elixir)
RUN cd /tmp && \
    wget https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_20.1-1~ubuntu~xenial_amd64.deb && \
    dpkg -i esl-erlang_20.1-1~ubuntu~xenial_amd64.deb

# Install Kiex (Elixir version manager)
RUN \curl -sSL https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s

# INSTALL NODE JS
Run cd /tmp && \
    wget -qO- https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs

# INSTALL GO
RUN cd /tmp && \
    wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.11.1.linux-amd64.tar.gz

RUN echo "" >> /root/.bashrc && \
    echo "# Go Support" >> /root/.bashrc && \
    echo "export PATH=\$PATH:/usr/local/go/bin" >> /root/.bashrc

# Support for Elixir
RUN apt-get install -y locales && \
    locale-gen --purge en_US.UTF-8

RUN dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:

RUN echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:"\n' > /etc/default/locale

# Install Elixir (via kiex)
RUN /root/.kiex/bin/kiex install 1.7.3

# Fix environment and path issue for elixir install
RUN mv /root/.kiex/elixirs/elixir-1.7.3.env /root/.kiex/elixirs/elixir-1.7.3.env.ORIG
COPY patch_elixir_173_env.txt /root/.kiex/elixirs/elixir-1.7.3.env

# Install rvm (Ruby Version Manager)
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    \curl -sSL https://get.rvm.io | bash -s stable

RUN /bin/bash -l -c 'source /etc/profile.d/rvm.sh'

# Set bundler as a default gem
RUN echo bundler >> /usr/local/rvm/gemsets/global.gems

# Setup some default flags from rvm (auto install, auto gemset create, quiet curl)
RUN echo "rvm_install_on_use_flag=1\nrvm_gemset_create_on_use_flag=1\nrvm_quiet_curl_flag=1" > ~/.rvmrc

# Preinstall some ruby versions
ENV PREINSTALLED_RUBIES "2.5.3 2.4.1 2.3.5"
RUN /bin/bash -l -c 'for version in $PREINSTALLED_RUBIES; do echo "Now installing Ruby $version"; rvm install $version; rvm cleanup all; done'

# Add .bashrc.local file with aliases to address RVM and Elixir conflict due to PATH
RUN touch $HOME/.bashrc.local && \
    echo "# Alias patch work to address RVM & Elixir conflict over PATH setting" >> $HOME/.bashrc.local && \
    echo "alias elixir_go=\"source $HOME/.kiex/elixirs/elixir-1.7.3.env\"" >> $HOME/.bashrc.local && \
    echo "alias reset_path=\"export PATH=/usr/local/rvm/gems/ruby-2.5.1/bin:/usr/local/rvm/gems/ruby-2.5.1@global/bin:/usr/local/rvm/rubies/ruby-2.5.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin:/usr/local/go/bin\"" >> $HOME/.bashrc.local && \
    echo "" >> $HOME/.bashrc && \
    echo "# Pull in aliases and other settings from bashrc.local file" >> $HOME/.bashrc && \
    echo "source $HOME/.bashrc.local" >> $HOME/.bashrc

# Customize vim based off of repo: https://github.com/hogihung/docker-vim-demo
RUN cd /root && \
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && \
    git clone https://github.com/lifepillar/vim-solarized8.git ~/.vim/pack/themes/opt/solarized8 && \
    apt-get install -y dos2unix

COPY dot_vimrc /root/.vimrc

RUN dos2unix /root/.vimrc && \
    vim +PluginInstall +qall

# Login shell by default so rvm is sourced automatically and 'rvm use' can be used
ENTRYPOINT /bin/bash -l
