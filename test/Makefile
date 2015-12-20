## makefile for updating the assert.sh script
NAME = flyhard/docker-mailserver
VERSION = $(TRAVIS_BUILD_ID)

all: update test

run:
	# Copy test files
	-rm -rf test-config
	mkdir test-config
	cp -ra ../postfix/* test-config/
	cp accounts.cf test-config/
	cp virtual test-config/
	# Run container
	-docker stop mail
	-docker rm mail
	docker run -d --name mail -h mail.my-domain.com -t $(NAME):$(VERSION)
	docker cp test-config mail:/tmp/postfix
	docker cp ../spamassassin mail:/tmp/spamassassin
	docker exec mail mkdir /tmp/test
	docker cp email-templates mail:/tmp/test/email-templates
	docker cp postgrey mail:/tmp/test/postgrey
	docker stop mail
	docker start mail

prepare: run
	docker exec mail /bin/sh -c "while ! echo QUIT |nc localhost 25; do sleep 2; done"
	# Reinitialize logs
	docker exec mail /bin/sh -c 'echo "" > /var/log/mail.log'

fixtures: prepare
	# Sending test mails
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/amavis-spam.txt"
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/amavis-virus.txt"
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/existing-alias-external.txt"
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/existing-alias-local.txt"
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/existing-user.txt"
	docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/test/email-templates/non-existing-user.txt"
	docker exec mail /bin/bash -c "nc -q 1 localhost 10023 < /tmp/test/postgrey/standardTest.txt"
	# Wait for mails to be analyzed
	sleep 10

update:
	-wget -q https://raw.github.com/lehmannro/assert.sh/master/assert.sh -O assert.sh.new && mv assert.sh.new assert.sh

test: update fixtures
	/bin/bash ./test.sh

stop: run
	docker stop mail
	docker rm mail

shell: run
	docker exec -it mail bash
