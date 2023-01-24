IMAGE_NAME:=hub.cstcloud.cn/app/code-former
IMAGE_FILE:=/mydata/tmp/my.img

build:
	DOCKER_BUILDKIT=1 docker build --network=host -t $(IMAGE_NAME) .

push:
	docker push $(IMAGE_NAME)

clean:
	docker rmi $(IMAGE_NAME)

dist:
	docker save $(IMAGE_NAME) > $(IMAGE_FILE)
	pdsh -w b0[1-9],b10,r0[1-9],r1[0-9],r20 -l root "docker load < $(IMAGE_FILE)" | dshbak -c
	# for i in {0..3}; do echo $$i; ssh n$$i docker load < $(IMAGE_FILE); done 
	rm -f $(IMAGE_FILE)

run:
	docker run -it --network=host --rm \
		--runtime=nvidia --cap-add SYS_ADMIN --ipc=host --gpus device=0 \
		-e CUDA_VISIBLE_DEVICES=0 -v /var/log/nvidia-mps:/var/log/nvidia-mps \
		-v /data/CodeFormer/weights:/CodeFormer/weights \
		-v /tmp/CodeFormer/inputs:/CodeFormer/inputs \
		-v /tmp/CodeFormer/results:/CodeFormer/results \
		-w /CodeFormer $(IMAGE_NAME)

sync:
	rsync -av . --del -e "ssh -J root@qiu-h1" root@g8:/tmp/CodeFormer

sync-back:
	rsync -av -e "ssh -J root@qiu-h1" root@g8:/tmp/CodeFormer ~/Desktop/
