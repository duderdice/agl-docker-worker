# ---------------------------------------------------
# --- base variables
# ---------------------------------------------------
REGISTRY=docker.automotivelinux.org
REPO=agl
NAME=worker
VERSION=2.1

# ---------------------------------------------------
# --- computed - don't touch !
# ---------------------------------------------------

IMAGE_NAME=$(REGISTRY)/$(REPO)/$(NAME):$(VERSION)
IMAGE_LATEST=$(REGISTRY)/$(REPO)/$(NAME):latest
CNAME=vm-$(NAME)

help:
	@echo "Available targets:"
	@echo "- clean: drop existing container and image"
	@echo "- distclean: drop temp images (the one produced by a bad Dockerfile...)"
	@echo "- build: create new image"
	@echo "- test: start a new test container and enter in it. After exit, the container is destoyed"
	@echo "- push: push the image to registry $(REGISTRY)"
	@echo "- push-latest: push the image to registry $(REGISTRY) and also tag as 'latest'"
	@echo "- export: export the image to a compressed archive"
	@echo "- export-latest: export the latest image to a compressed archive"
	@echo ""
	@echo "Variables:"
	@echo "- Docker registry:           REGISTRY=$(REGISTRY)"
	@echo "- Image repository:          REPO=$(REPO)"
	@echo "- Image name:                NAME=$(NAME)"
	@echo "- Image version:             VERSION=$(VERSION)"
	@echo "- Container name/host name:  CNAME=$(CNAME)"
	@echo
	@echo "Containers:"
	@docker ps -a
	@echo
	@echo "Images:"
	@docker images
	@echo

.PHONY:clean
clean: 
	@docker inspect $(CNAME) &>/dev/null && { \
		echo "Stopping and removing container $(CNAME)" ; \
		docker stop $(CNAME) || true; \
		docker rm $(CNAME); \
	} || true
	@docker inspect $(IMAGE_NAME) &>/dev/null && { \
		echo "Removing image $(IMAGE_NAME)"; \
		docker rmi $(IMAGE_NAME) ; \
	} || true
	@docker inspect $(IMAGE_LATEST) &>/dev/null && { \
		echo "Removing image $(IMAGE_LATEST)"; \
		docker rmi $(IMAGE_LATEST) ; \
	} || true

# remove spurious containers and images left by broken builds
.PHONY:distclean
distclean: clean
	@for imgid in $$(docker images | grep "^<none>" | awk '{print $$3}'); do \
		for cntid in $$(docker ps -a -f ancestor=$$imgid --format "{{.ID}}"); do \
			echo "Stop container $$cntid"; \
			docker stop $$cntid; \
			echo "Remove container $$cntid"; \
			docker rm $$cntid; \
		done; \
		echo "Remove image $$imgid"; \
		docker rmi $$imgid; \
	done

.PHONY:build 
build: 
	@echo "------------------- Building image $(NAME) -------------------"; \
	docker build --no-cache=true --rm --pull -t $(IMAGE_NAME) .
	docker images

.PHONY:test
test:
	docker run \
		--detach=true \
		--hostname=$(CNAME) \
		--name=$(CNAME) \
		--privileged \
		-it \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		$(IMAGE_NAME)
	docker exec -it $(CNAME) /bin/bash || true
	docker stop $(CNAME) || true
	docker rm $(CNAME) || true

.PHONY:push
push:
	docker push $(IMAGE_NAME)

.PHONY:push-latest
push-latest: push
	docker tag -f $(IMAGE_NAME) $(IMAGE_LATEST)
	docker push $(IMAGE_LATEST)

.PHONY:export
export:
	@echo "Export image to docker_$(REPO)_$(NAME)-$(VERSION).tar.xz"
	docker save $(IMAGE_NAME) | xz -T0 -c >docker_$(REPO)_$(NAME)-$(VERSION).tar.xz

