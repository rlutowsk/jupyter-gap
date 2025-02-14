PACKAGE := rlutowsk/jupyter-gap

.PHONY: all slim latest devel

all: latest

slim: latest

latest: Dockerfile
	docker buildx build -t ${PACKAGE}:latest .

devel: Dockerfile.devel
	docker buildx build -t ${PACKAGE}:devel -f Dockerfile.devel .
