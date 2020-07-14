all: build test stop

# this is to forward X apps to host:
# See: http://stackoverflow.com/a/25280523/1336939
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

# paths
TBB_PATH=/home/docker/tbcrawl/tor-browser_en-US/
CRAWL_PATH=/home/docker/tbcrawl
GUEST_SSH=/home/docker/.ssh
HOST_SSH=${HOME}/.ssh

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
	docker build -t tbcrawl --rm .

run:
	docker run -it --rm ${ENV_VARS} ${VOLUMES} --user=$(id -u):$(id -g) --privileged tbcrawl ${CRAWL_PATH}/Entrypoint.sh "$(PARAMS)"

run_bbr:
	docker run -it --rm ${ENV_VARS} ${VOLUMES} --user=$(id -u):$(id -g) --privileged tbcrawl ${CRAWL_PATH}/Entrypoint.sh "$(PARAMS) -o bbr"

run_cubic:
	docker run -it --rm ${ENV_VARS} ${VOLUMES} --user=$(id -u):$(id -g) --privileged tbcrawl ${CRAWL_PATH}/Entrypoint.sh "$(PARAMS) -o cubic"

run_reno:
	docker run -it --rm ${ENV_VARS} ${VOLUMES} --user=$(id -u):$(id -g) --privileged tbcrawl ${CRAWL_PATH}/Entrypoint.sh "$(PARAMS) -o reno"

stop:
	@docker stop `docker ps -a -q -f ancestor=tbcrawl:latest`
	@docker rm `docker ps -a -q -f ancestor=tbcrawl:latest`

destroy:
	@docker rmi -f tbcrawl

reset: stop destroy
