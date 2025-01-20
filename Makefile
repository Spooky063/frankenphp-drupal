image_name := frankenphp-drupal
tag_name := 1-php8.4-drupal11
image_full_name := $(image_name):$(tag_name)
container_id = $(shell docker container ls --all --filter "name=$(image_name)" --quiet)

.PHONY: build
build:
	docker build \
		--build-arg PHP_VERSION=8.4 \
		--build-arg FRANKENPHP_VERSION=1 \
		--build-arg DRUPAL_VERSION=11.x-dev \
		-t $(image_full_name) .

.PHONY: delete-build
delete-build:
	docker image rm -f $(image_full_name)
	docker rm $(image_name)

.PHONY: run
run:
	docker run -it --name "$(image_name)" \
	-p 80:80 \
	-e SIMPLETEST_DB=sqlite://sites/default/files/.test.sqlite \
	$(image_full_name)

.PHONY: ssh
ssh:
	docker exec -it $(container_id) bash