VERSION = "unset"
DATE=$(shell date -u +%Y-%m-%d-%H:%M:%S-%Z)
.PHONY: build
build:
	cd cmd/proxy && go build

build-ver:
	GO111MODULE=on CGO_ENABLED=0 go build -mod=vendor -ldflags "-X github.com/gomods/athens/pkg/build.version=$(VERSION) -X github.com/gomods/athens/pkg/build.buildDate=$(DATE)" -o athens ./cmd/proxy

.PHONY: run
run: build
	./athens

.PHONY: docs
docs:
	docker build -t gomods/hugo -f docs/Dockerfile .

.PHONY: setup-dev-env
setup-dev-env:
	./scripts/get_dev_tools.sh
	$(MAKE) dev

.PHONY: verify
verify:
	./scripts/check_gofmt.sh
	./scripts/check_golint.sh
	./scripts/check_deps.sh
	./scripts/check_conflicts.sh

.PHONY: test
test:
	cd cmd/proxy && buffalo test

.PHONY: test-unit
test-unit:
	./scripts/test_unit.sh

.PHONY: test-e2e
test-e2e:
	./scripts/test_e2e.sh

.PHONY: docker
docker: proxy-docker

.PHONY: proxy-docker
proxy-docker:
	docker build -t gomods/athens -f cmd/proxy/Dockerfile .

.PHONY: docker-push
docker-push:
	./scripts/push-docker-images.sh

bench:
	./scripts/benchmark.sh

.PHONY: alldeps
alldeps:
	docker-compose -p athensdev up -d mongo
	docker-compose -p athensdev up -d minio
	docker-compose -p athensdev up -d jaeger
	echo "sleeping for a bit to wait for the DB to come up"
	sleep 5

.PHONY: dev
dev:
	docker-compose -p athensdev up -d mongo
	docker-compose -p athensdev up -d minio

.PHONY: down
down:
	docker-compose -p athensdev down -v

.PHONY: dev-teardown
dev-teardown:
	docker-compose -p athensdev down -v
