
include .env

TAG=$(shell git rev-parse --short HEAD)

REPO="elimayost/nyc"

docker-login:
	@-docker login -u $(DOCKER_USER) -p '$(DOCKER_PASS)'

build-image: docker-login
	@-docker build -t $(REPO):$(TAG) .
	@-docker tag $(REPO):$(TAG) $(REPO):latest

push-image: docker-login
	@-docker push $(REPO):$(TAG)
	@-docker push $(REPO):latest

build-and-push: docker-login build-image push-image

install-argo:
	@-kubectl apply -f k8s/install.yaml

uninstall-argo:
	@-kubectl delete -f k8s/install.yaml

get-login-token:
	@-echo "Bearer" $(shell kubectl -n argo get secret argo-token -o jsonpath='{.data.token}' | base64 --decode)

deploy-cron:
	@-argo cron create $(cron)
