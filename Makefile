NAME := MpegUrlKit

all: init synx format test podlint

ci: init test podlint

init:
	bundle install --path vendor/bundle
	bundle exec pod install

open:
	open ${NAME}.xcworkspace

test:
	xcodebuild -workspace ${NAME}.xcworkspace -scheme ${NAME}Workspace -sdk iphonesimulator -verbose \
		-destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' \
		-destination 'platform=iOS Simulator,name=iPhone 6,OS=9.0' \
		-destination 'platform=iOS Simulator,name=iPhone 6,OS=10.0' \
		-destination 'platform=iOS Simulator,name=iPhone 7,OS=10.1' \
		clean test

podlint:
	bundle exec pod lib lint --use-libraries

synx:
	bundle exec synx ${NAME}.xcodeproj

format:
	find ${NAME}* -type f -regex ".*\.[m,h]$$" | xargs clang-format -i
