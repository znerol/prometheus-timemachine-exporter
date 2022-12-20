# Copyright 2022 Lorenz Schori
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

all:: vet timemachine_exporter

vet:
	go vet

build/timemachine_exporter-darwin-arm64: vet
	mkdir -p build
	GOOS=darwin GOARCH=arm64 go build -o ./build/timemachine_exporter-darwin-arm64 main.go

build/timemachine_exporter-darwin-amd64: vet
	mkdir -p build
	GOOS=darwin GOARCH=amd64 go build -o ./build/timemachine_exporter-darwin-amd64 main.go

LIPO := $(shell command -v lipo 2> /dev/null)

build/timemachine_exporter: build/timemachine_exporter-darwin-arm64 build/timemachine_exporter-darwin-amd64
ifndef LIPO
	$(warning "lipo is not available")
	$(warning "install apple developer tools in order to build an universal binary")
else
	lipo -create -output ./build/timemachine_exporter ./build/timemachine_exporter-darwin-amd64 ./build/timemachine_exporter-darwin-arm64
	chmod +x ./build/timemachine_exporter
endif

clean:
	rm -rf build dist

VERSION := $(shell git describe --tags --always)

build: build/timemachine_exporter
	mkdir -p build/timemachine_exporter-${VERSION}
	cp LICENSE.txt build/timemachine_exporter build/timemachine_exporter-${VERSION}

dist: build
	mkdir -p dist
	tar --uid 0 --gid 0 --numeric-owner -czf dist/timemachine_exporter-${VERSION}.tar.gz -C build timemachine_exporter-${VERSION}
	(cd dist && shasum -a 256 timemachine_exporter > sha256sums.txt)
