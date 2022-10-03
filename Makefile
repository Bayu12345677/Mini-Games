test:
	$(shell command -v bash) -c 'source lib/moduler.sh'
run:
	chmod 750 app.sh
	./app.sh
