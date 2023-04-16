IMAGE_NAME := asia-southeast1-docker.pkg.dev/wedding-card-383908/line-noti/axum_line_noti
dev: 
	cargo watch -x 'run'

docker-build-gcp: 
	docker build -t ${IMAGE_NAME} --platform=linux/amd64 .

docker-push-gcp: 
	docker push ${IMAGE_NAME}

