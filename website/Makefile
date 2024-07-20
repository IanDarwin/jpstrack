GENERATED = index.html privacy.html RELEASE_NOTES.html
install:	$(GENERATED)
	echo "Don't install v2 website until on Google Play!"
	exit 1
	cp -r * /var/www/htdocs/darwinsys.com/jpstrack
index.html:	index.adoc
	asciidoctor index.adoc
privacy.html:	privacy.adoc
	asciidoctor privacy.adoc
RELEASE_NOTES.html:	RELEASE_NOTES.adoc
	asciidoctor RELEASE_NOTES.adoc
