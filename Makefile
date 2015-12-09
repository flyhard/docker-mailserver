NAME = flyhard/docker-mailserver
VERSION = $(TRAVIS_BUILD_ID)

all: build run prepare fixtures tests stop

build:
	docker build -t $(NAME):$(VERSION) .

run:
	# Copy test files
	-rm -rf test-config
	mkdir test-config
	cp -ra postfix/* test-config/
	cp test/accounts.cf test-config/
	cp test/virtual test-config/
	# Run container
	-docker stop mail
	-docker rm mail
	docker run -d --name mail -v "`pwd`/test-config":/tmp/postfix -v "`pwd`/spamassassin":/tmp/spamassassin -v \
	"`pwd`/test":/tmp/test -h mail.my-domain.com -t $(NAME):$(VERSION)
	docker exec mail /bin/sh -c "while ! echo QUIT |nc localhost 25; do sleep 2; done"

prepare:
	# Reinitialize logs 
	docker exec mail /bin/sh -c 'echo "" > /var/log/mail.log'

fixtures:
	# Sending test mails
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/amavis-spam.txt"		
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/amavis-virus.txt"		
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/existing-alias-external.txt"		
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/existing-alias-local.txt"		
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/existing-user.txt"		
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/non-existing-user.txt"
	# Wait for mails to be analyzed
	sleep 10

tests:
	# Start tests
	/bin/bash ./test/test.sh

stop:
	docker stop mail
	docker rm mail
