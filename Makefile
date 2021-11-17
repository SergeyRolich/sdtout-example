.PHONY: build docker run-docker run-all

build:
	 CGO_ENABLED=0 go build -o stdout-app main.go

docker:
	docker build . -t stdout-example

run-docker:
	docker run --rm -it stdout-example

run-all: docker run-docker
