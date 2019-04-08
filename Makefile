DOCKER=sudo docker
IMAGE=dokusho_imgae
BOARDIMAGE=dokusho_board
CONTAINER=dokusho_container
BOARDCONTAINER=dokusho_board_container
TMP=tmp.yml
CONFIG=config.yml

NV_GPU=`grep "NV_GPU[^_]" $(TMP) | awk -F' *: *' '{ print $$2 }'`
DATA_DIR=`grep DATA_DIR_PATH $(TMP) | awk -F' *: *' '{ print $$2 }'`
LOG_DIR=`grep LOG_DIR_PATH $(TMP) | awk -F' *: *' '{ print $$2 }'`
MODEL_DIR=`grep MODEL_DIR_PATH $(TMP) | awk -F' *: *' '{ print $$2 }'`
JUPYTER_NOTEBOOK_PORT=`grep JUPYTER_NOTEBOOK_PORT $(TMP) | awk -F' *: *' '{ print $$2 }'`
TENSORBOARD_PORT=`grep TENDORBOARD_PORT $(TMP) | awk -F' *: *' '{ print $$2 }'`

$(TMP): $(CONFIG)
	echo -n "# " >src/$(TMP)
	date >> src/$(TMP)
	grep -v "#" $(CONFIG) >> src/$(TMP)
	rm -f $(TMP)
	ln -s src/$(TMP)

dir: $(TMP)
	mkdir $(LOG_DIR) > /dev/null 2>&1 || :
	mkdir $(MODEL_DIR) > /dev/null 2>&1 ||:
	mkdir $(DATA_DIR) > /dev/null 2>&1 ||:
	touch dir

build: $(TMP) Dockerfile
	$(DOCKER) build -t $(IMAGE) -f Dockerfile .
	@touch build

run: build dir
	$(DOCKER) rm -f $(CONTAINER) 1>/dev/null 2>&1 || :
	$(DOCKER) run \
			--runtime=nvidia \
			-e NVIDIA_VISIBLE_DEVICES=$(NV_GPU) \
			--name $(CONTAINER) \
			-d \
			-it \
			-v $$PWD/src:/notebooks/work \
			-v $$PWD/$(DATA_DIR):/notebooks/work/$(DATA_DIR) \
			-v $$PWD/$(LOG_DIR):/notebooks/work/$(LOG_DIR) \
			-v $$PWD/$(MODEL_DIR):/notebooks/work/$(MODEL_DIR) \
			-p $(JUPYTER_NOTEBOOK_PORT):8899 \
			$(IMAGE)
	@sleep 5
	@touch run

run_local: build dir
	$(DOCKER) rm -f $(CONTAINER) 1>/dev/null 2>&1 || :
	$(DOCKER) run \
			-e NVIDIA_VISIBLE_DEVICES=$(NV_GPU) \
			--name $(CONTAINER) \
			-d \
			-it \
			-v $$PWD/src:/notebooks/work \
			-v $$PWD/$(DATA_DIR):/notebooks/work/$(DATA_DIR) \
			-v $$PWD/$(LOG_DIR):/notebooks/work/$(LOG_DIR) \
			-v $$PWD/$(MODEL_DIR):/notebooks/work/$(MODEL_DIR) \
			-p $(JUPYTER_NOTEBOOK_PORT):8899 \
			$(IMAGE)
	@sleep 5
	@touch run_local

show_url: run
	@$(DOCKER) logs $(CONTAINER) | grep "http://0.0.0.0:8899/?token=" | tail -1

show_url_local: run_local
	@$(DOCKER) logs $(CONTAINER) | grep "http://0.0.0.0:8899/?token=" | tail -1

bash: run
	$(DOCKER) exec -it $(CONTAINER) /bin/bash

bash_local: run_local
	$(DOCKER) exec -it $(CONTAINER) /bin/bash

clean:
	$(DOCKER) rm -f $(CONTAINER) 1>/dev/null 2>&1 || :
	rm -f $(TMP) dir build run 

clean_local:
	$(DOCKER) rm -f $(CONTAINER) 1>/dev/null 2>&1 || :
	rm -f $(TMP) dir build run_local 

build_board: Dockerfile_board
	$(DOCKER) build -t $(BOARDIMAGE) -f Dockerfile_board .
	@touch build_board

run_board: build_board
	$(DOCKER) rm -f $(BOARDCONTAINER) 1>/dev/null 2>&1 ||:
	$(DOCKER) run \
			--rm \
			-d \
			-it \
			--name $(BOARDCONTAINER) \
			-v $$PWD/tmp_board:/tmp \
			-v $$PWD/logs:/logs \
			-p 9988:9988 \
			$(BOARDIMAGE)
	@sleep 5
	@touch run_board

show_url_board: run_board
	@$(DOCKER) logs $(BOARDCONTAINER) | grep "http://0.0.0.0:9988" | tail -1

clean_board:
	$(DOCKER) rm -f $(BOARDCONTAINER) 1>/dev/null 2>&1 || :
	rm -f $(TMP) build_board run_board
