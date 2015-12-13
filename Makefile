NAME = flyhard/docker-mailserver
VERSION = $(TRAVIS_BUILD_ID)

all: build tests

build:
	docker build -t $(NAME):$(VERSION) .

tests: build
	# Start tests
	NAME=$(NAME) VERSION=$(VERSION) $(MAKE) -C test

