PACKAGE := rlutowsk/jupyter-gap

PLATFORMS := linux/amd64,linux/arm64

OPTS := --platform ${PLATFORMS} --pull

.PHONY: all slim latest devel

all: latest devel full

slim: latest

latest: Dockerfile
	docker buildx build --provenance=true --sbom=true -t ${PACKAGE}:latest ${OPTS} .

devel: Dockerfile.devel
	docker buildx build --provenance=true --sbom=true -f Dockerfile.devel -t ${PACKAGE}:devel ${OPTS} .

full: Dockerfile.full
	docker buildx build --provenance=true --sbom=true -f Dockerfile.full -t ${PACKAGE}:full ${OPTS} .