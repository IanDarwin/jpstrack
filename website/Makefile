GENERATED = index.html privacy.html RELEASE_NOTES.html
all:		$(GENERATED)
index.html:	index.adoc
	asciidoctor index.adoc
privacy.html:	privacy.adoc
	asciidoctor privacy.adoc
RELEASE_NOTES.html:	RELEASE_NOTES.adoc
	asciidoctor RELEASE_NOTES.adoc
install:	$(GENERATED)
	git pull
	cp -r * /var/www/htdocs/darwinsys.com/jpstrack
