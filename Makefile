.PHONY: all clean build run

all: build run

clean:
	@echo "cleaning things"
	docker kill docker-novnc && echo "stopped container" || /bin/true
	docker rm docker-novnc && echo "removed container" || /bin/true
	docker rmi t4skforce/docker-novnc:latest && echo "removed container image" || /bin/true

build:
	@echo "building things"
	docker build -t t4skforce/docker-novnc:latest .

debug:
	@echo "debugging things"
	docker run --name docker-novnc -it -p 127.0.0.1:8080:8080/tcp -p 127.0.0.1:8443:8443/tcp -e REVERSE_PROXY=yes -e CRONJOBS=no -e APP_USERNAME=admin -e APP_PASSWORD=admin -v ~/data:/data:rw --rm t4skforce/docker-novnc:latest /bin/bash

run:
	@echo "runing things"
	docker run --name docker-novnc -it -p 127.0.0.1:8080:8080/tcp -p 127.0.0.1:8443:8443/tcp -e REVERSE_PROXY=no -e CRONJOBS=yes -e APP_USERNAME=admin -e APP_PASSWORD=admin -v ~/data:/data:rw --rm t4skforce/docker-novnc:latest
