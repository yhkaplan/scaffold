
release_build:
	swift build --configuration release --disable-sandbox

install: release_build
	cp .build/release/scaffold "$$(brew --prefix)/bin/"
