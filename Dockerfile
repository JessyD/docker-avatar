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
    python-dev \
    python-pip \
    python \
    vim \
    wget \
    zsh

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
RUN cd tvb-library && git reset --hard 6773f66 && cd ..
RUN cd tvb-library && python setup.py develop install && cd ..
RUN git clone https://github.com/the-virtual-brain/tvb-data.git
RUN cd tvb-data && git reset --hard 7d2d05b && cd ..
RUN cd tvb-data && python setup.py develop install && cd ..
# RUN git clone --branch 1.5.4 https://github.com/the-virtual-brain/tvb-framework.git
# RUN cd tvb-framework && python setup.py develop install && cd ..
WORKDIR /

ENTRYPOINT /bin/zsh
