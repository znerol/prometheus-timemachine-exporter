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

VERSION := $(shell git describe --tags --always)

all: build

.build/apple/Products/Release/timemachine_exporter:
	swift build -c release --arch arm64 --arch x86_64

clean:
	rm -rf .build build dist

build: .build/apple/Products/Release/timemachine_exporter
	mkdir -p build/timemachine_exporter-${VERSION}
	cp LICENSE.txt .build/apple/Products/Release/timemachine_exporter build/timemachine_exporter-${VERSION}

dist: build
	mkdir -p dist
	tar --uid 0 --gid 0 --numeric-owner -czf dist/timemachine_exporter-${VERSION}.tar.gz -C build timemachine_exporter-${VERSION}
	(cd dist && shasum -a 256 timemachine_exporter-* > sha256sums.txt)
