MAJOR	?= 4
MINOR	?= 3
PATCH	?= 0

TAG	= g0dscookie/pdns
TAGLIST = -t ${TAG}:${MAJOR} -t ${TAG}:${MAJOR}.${MINOR} -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}
BUILDARGS = --build-arg MAJOR=${MAJOR} --build-arg MINOR=${MINOR} --build-arg PATCH=${PATCH}

PLATFORM_FLAGS	= --platform linux/amd64 --platform linux/386 --platform linux/arm64 --platform linux/arm/v6 --platform linux/arm/v7

build:
	docker buildx build --push ${PLATFORM_FLAGS} ${BUILDARGS} ${TAGLIST} .

latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
latest: build
.PHONY: build latest

amd64: PLATFORM_FLAGS := --platform linux/amd64
amd64: build
amd64-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
amd64-latest: amd64
.PHONY: amd64 amd64-latest

i386: PLATFORM_FLAGS := --platform linux/386
i386: build
i386-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
i386-latest: i386
.PHONY: i386 i386-latest

arm64: PLATFORM_FLAGS := --platform linux/arm64
arm64: build
arm64-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
arm64-latest: arm64
.PHONY: arm64 arm64-latest

armv6: PLATFORM_FLAGS := --platform linux/arm/v6
armv6: build
armv6-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
armv6-latest: armv6
.PHONY: armv6 armv6-latest

armv7: PLATFORM_FLAGS := --platform linux/arm/v7
armv7: build
armv7-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
armv7-latest: armv7
.PHONY: armv7 armv7-latest
