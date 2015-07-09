DOCKER_IMAGE_NAME=tenstartups/backup-service

build: Dockerfile
	docker build -t ${DOCKER_IMAGE_NAME} .

run: build
	docker run -it --rm ${DOCKER_IMAGE_NAME} ${ARGS}
