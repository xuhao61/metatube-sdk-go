MODULE := github.com/javtube/javtube-sdk-go

SERVER_NAME := javtube-server
SERVER_CODE := cmd/server/main.go

BUILD_DIR     := build
BUILD_TAGS    :=
BUILD_FLAGS   := -v
BUILD_COMMIT  := $(shell git rev-parse --short HEAD)
BUILD_VERSION := $(shell git describe --abbrev=0 --tags HEAD)

CGO_ENABLED := 0
GO111MODULE := on

LDFLAGS += -w -s -buildid=
LDFLAGS += -X "$(MODULE)/internal/constant.Version=$(BUILD_VERSION)"
LDFLAGS += -X "$(MODULE)/internal/constant.GitCommit=$(BUILD_COMMIT)"

GO_BUILD = GO111MODULE=$(GO111MODULE) CGO_ENABLED=$(CGO_ENABLED) \
	go build $(BUILD_FLAGS) -ldflags '$(LDFLAGS)' -tags '$(BUILD_TAGS)' -trimpath

UNIX_ARCH_LIST = \
	darwin-amd64 \
	darwin-amd64-v3 \
	darwin-arm64 \
	linux-386 \
	linux-amd64 \
	linux-amd64-v3 \
	linux-arm64 \
	linux-armv5 \
	linux-armv6 \
	linux-armv7

WINDOWS_ARCH_LIST = \
	windows-386 \
	windows-amd64 \
	windows-amd64-v3 \
	windows-arm64

all: server

server:
	$(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME) $(SERVER_CODE)

darwin-amd64:
	GOARCH=amd64 GOOS=darwin $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

darwin-amd64-v3:
	GOARCH=amd64 GOOS=darwin GOAMD64=v3 $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

darwin-arm64:
	GOARCH=arm64 GOOS=darwin $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

linux-386:
	GOARCH=386 GOOS=linux $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

linux-amd64:
	GOARCH=amd64 GOOS=linux $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

linux-amd64-v3:
	GOARCH=amd64 GOOS=linux GOAMD64=v3 $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

linux-arm64:
	GOARCH=arm64 GOOS=linux $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

linux-armv5:
	GOARCH=arm GOARM=5 GOOS=linux $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

linux-armv6:
	GOARCH=arm GOARM=6 GOOS=linux $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

linux-armv7:
	GOARCH=arm GOARM=7 GOOS=linux $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@ $(SERVER_CODE)

windows-386:
	GOARCH=386 GOOS=windows $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@.exe $(SERVER_CODE)

windows-amd64:
	GOARCH=amd64 GOOS=windows $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@.exe $(SERVER_CODE)

windows-amd64-v3:
	GOARCH=amd64 GOOS=windows GOAMD64=v3 $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@.exe $(SERVER_CODE)

windows-arm64:
	GOARCH=arm64 GOOS=windows $(GO_BUILD) -o $(BUILD_DIR)/$(SERVER_NAME)-$@.exe $(SERVER_CODE)

unix_releases := $(addsuffix .zip, $(UNIX_ARCH_LIST))
windows_releases := $(addsuffix .zip, $(WINDOWS_ARCH_LIST))

$(unix_releases): %.zip: %
	@zip -qmj $(BUILD_DIR)/$(SERVER_NAME)-$(basename $@).zip $(BUILD_DIR)/$(SERVER_NAME)-$(basename $@)

$(windows_releases): %.zip: %
	@zip -qmj $(BUILD_DIR)/$(SERVER_NAME)-$(basename $@).zip $(BUILD_DIR)/$(SERVER_NAME)-$(basename $@).exe

all-arch: $(UNIX_ARCH_LIST) $(WINDOWS_ARCH_LIST)

releases: $(unix_releases) $(windows_releases)

lint:
	golangci-lint run --disable-all -E govet -E gofumpt -E megacheck ./...

clean:
	rm -rf $(BUILD_DIR)