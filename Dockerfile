FROM ubuntu:17.10

MAINTAINER Jessica Dafflon <jejedafflon@gmail.com>

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Update the apt cache.
RUN apt-get update

# Install packages.
RUN apt-get install -y \
    build-essential \
    git \
    htop \
    python-dev \
    python-pip \
    python \
    vim \
    wget \
    zsh \
    python-tk \
    bc

# Install oh-my-zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

# Install Python requirements.
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt

# Install the TVB packages.
# Note: tvb-data does not have a valid tag, so we fetch a specific SHA.
WORKDIR /tmp
RUN git clone https://github.com/the-virtual-brain/tvb-library.git
# If the SHA does not work, this commit was done 2017.09.28 with the title "Merge
# remote-tracking branch 'origin/trunk' into trunk"
RUN cd tvb-library && git reset --hard 6773f66 && cd ..
RUN cd tvb-library && python setup.py develop install && cd ..
RUN git clone https://github.com/the-virtual-brain/tvb-data.git
# If the SHA does not work, this commit was done 2017.12.14 with the title
# "Merge branch 'master' of https://github.com/the-virtual-brain/tvb-data"
RUN cd tvb-data && git reset --hard 7d2d05b && cd ..
RUN cd tvb-data && python setup.py develop install && cd ..
# RUN git clone --branch 1.5.4 https://github.com/the-virtual-brain/tvb-framework.git
# RUN cd tvb-framework && python setup.py develop install && cd ..

# Get my vim into the docker container
RUN git clone https://github.com/JessyD/dot-cloud.git
RUN ln -s /tmp/dot-cloud/vimrc /root/.vimrc
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
RUN vim +PluginInstall +qall

# Make sure the shell always shows that we are in a docker container.
RUN echo "PROMPT=\"(docker) \$PROMPT\"" >> $HOME/.zshrc

# Always start at home.
WORKDIR /root

ENTRYPOINT /bin/zsh
