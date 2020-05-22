
release_build:
	swift build --configuration release --disable-sandbox --disable-package-manifest-caching

install: release_build
	cp .build/release/scaffold /usr/local/bin/
