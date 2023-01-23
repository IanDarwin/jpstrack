push:
	git push origin master; git push backup master
release release-packages appbundles:
	@echo "************************************************"
	@echo "**     Building releases for Android, iOS     **"
	@echo "* build# in pubspec.yaml is $$(awk '/^version/{print $2}' pubspec.yaml) * "
	@echo "************************************************"
	@echo Is that version and build correct?
	@echo Have you tested well?
	@echo And is everything checked in that should be:
	git status
	read answer # just type ^C if you want to stop
	@echo
	flutter build appbundle # Build an Android App Bundle file from your app.
	@echo
	flutter build ipa       # Build an iOS application bundle (Mac OS X host only).
	@echo

regen-icons:
	flutter pub run flutter_launcher_icons:main


