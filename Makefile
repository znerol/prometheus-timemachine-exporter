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

timemachine_exporter-darwin-arm64: vet
	GOOS=darwin GOARCH=arm64 go build -o ./timemachine_exporter-darwin-arm64 main.go

timemachine_exporter-darwin-amd64: vet
	GOOS=darwin GOARCH=amd64 go build -o ./timemachine_exporter-darwin-amd64 main.go

LIPO := $(shell command -v lipo 2> /dev/null)

timemachine_exporter: timemachine_exporter-darwin-arm64 timemachine_exporter-darwin-amd64
ifndef LIPO
	$(warning "lipo is not available")
	$(warning "install apple developer tools in order to build an universal binary")
else
	lipo -create -output timemachine_exporter timemachine_exporter-darwin-amd64 timemachine_exporter-darwin-arm64
	chmod +x timemachine_exporter
endif

clean:
	rm -rf timemachine_exporter timemachine_exporter-* dist

dist: timemachine_exporter
	mkdir -p dist
	cp timemachine_exporter dist/
	(cd dist && shasum -a 256 timemachine_exporter > sha256sums.txt)
