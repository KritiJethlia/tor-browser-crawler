# This dockerfile allows to run an crawl inside a docker container

# Pull base image.
FROM debian:stable-slim

# Install required packages.
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --yes install sudo build-essential autoconf git zip unzip xz-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --yes install libtool libevent-dev libssl-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --yes install python3.7 python3.7-dev python3-setuptools python3-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --yes install net-tools ethtool tshark libpcap-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --yes install xvfb firefox-esr
RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install python requirements.
RUN pip3 install --upgrade pip
RUN pip3 install requests

# add host user to container
RUN adduser --system --group --disabled-password --gecos '' --shell /bin/bash docker

# download geckodriver
ADD https://github.com/mozilla/geckodriver/releases/download/v0.26.0/geckodriver-v0.26.0-linux64.tar.gz /bin/
RUN tar -zxvf /bin/geckodriver* -C /bin/
ENV PATH /bin/geckodriver:$PATH

# add setup.py
RUN git clone https://gist.github.com/teuron/5124fb5c380964a24521dd1652ed57ae.git /home/docker/tbb_setup
RUN python3.7 /home/docker/tbb_setup/setup.py 9.5.1

# Set the display
ENV DISPLAY $DISPLAY
