.PHONY: all run

all: build run

TBB_PATH=/home/docker/tbcrawl/tor-browser_en-US/
CRAWL_PATH=/home/docker/tbcrawl
GUEST_SSH=/home/docker/.ssh
HOST_SSH=${HOME}/.ssh
CC_ALGOS = bbr cubic reno

ENV_VARS = \
	-e XDG_RUNTIME_DIR=/tmp 		\
	-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY}	\
	-e DISPLAY=${DISPLAY}  			\
	-e TBB_PATH=${TBB_PATH}

VOLUMES = \
	-v "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:/tmp/${WAYLAND_DISPLAY}"	\
	-v "${HOST_SSH}:${GUEST_SSH}"						\
	-v "`pwd`:${CRAWL_PATH}"						\

PARAMS=-c wang_and_goldberg -t WebFP -u ./etc/localized-urls-100-top.csv -s -x 1200x800

build:
	sudo apt-get update -y 
	sudo apt install net-tools -y
	sudo apt-get install tshark -y 
	sudo snap install docker
	docker build -t tbcrawl --rm .

run:
	sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
	sudo ifconfig eth0 mtu 1500
	sudo ethtool -K eth0 tx off rx off tso off gso off gro off lro off
	@for number in `seq 0 5`; do \
		for algo in $(CC_ALGOS); do \
			docker run --rm ${ENV_VARS} ${VOLUMES} --user=$(id -u):$(id -g) --sysctl net.ipv4.tcp_congestion_control=$$algo --privileged tbcrawl ${CRAWL_PATH}/Entrypoint.sh "$(PARAMS) -y $$number" ; \
		done \
	done

check_tso: 
	tshark -Tfields -e frame.len -r test.pcap | sort -u | head

run_limited:
	@docker run -it --rm ${ENV_VARS} ${VOLUMES} --user=$(id -u):$(id -g) --privileged tbcrawl 

stop:
	@docker stop `docker ps -a -q -f ancestor=tbcrawl:latest`
	@docker rm `docker ps -a -q -f ancestor=tbcrawl:latest`

destroy:
	@docker rmi -f tbcrawl

reset: stop destroy
