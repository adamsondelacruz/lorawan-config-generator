# Project settings
-include .env
PROJECT_NAME = amigo-rpi
HOME_DIR ?=amigo
export

all: generate 

install-python3:
	wget https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tar.xz
	tar xf Python-3.7.7.tar.xz
	cd Python-3.7.7
	./configure --enable-optimizations && \
	make -j -l 4 && \
	sudo make altinstall
	echo alias python3='python3.7' >> ~/.bashrc
	curl -O https://bootstrap.pypa.io/get-pip.py
	sudo python3.7 get-pip.py

install-gw:
	mkdir amigo
	sudo apt-get update -y
	sudo apt-get install git -y
	cd amigo && \
	git clone https://github.com/adamsondelacruz/picoGW_packet_forwarder.git && \
	git clone https://github.com/adamsondelacruz/picoGW_mcu.git && \
	git clone https://github.com/adamsondelacruz/picoGW_hal.git

install-dfu:
	sudo apt-get install autoconf -y 
	cd amigo && \
	git clone https://github.com/adamsondelacruz/dfu-util && \
	cd dfu-utl && \
	./autogen.sh && \
	sudo apt-get install libusb-1.0-0-dev -y && \
	./configure && make && sudo make install

compile-hal:
	cd ~/amigo/picoGW_hal	&& make clean all
	cd ~/amigo/picoGW_packet_forwarder && make clean all

generate:
	${INFO} "Generating global_conf.json"
	mkdir -p ~/${HOME_DIR}
	sed -e 's/{{NETWORK_SERVER}}/http:\/\/dev.ttn.iotninja.io/' \
		-e 's/{{PORT_UP}}/1700/' \
		-e 's/{{PORT_DOWN}}/1700/' <templates/frequency_plan/AS1-global_conf.json>~/${HOME_DIR}/global_conf.json

# Array function
define array
	$(1)=(); while read -r var; do $(1)+=("$$var"); done < <($(2))
endef


# Make settings
.PHONY: generate install-gw install-dfu compile-hal
.ONESHELL:
.SILENT:
SHELL=/bin/bash
.SHELLFLAGS = -ceo pipefail
YELLOW := "\e[1;33m"
RED := "\e[1;31m"
NC := "\e[0m"
INFO := @bash -c 'printf $(YELLOW); echo "=> $$0"; printf $(NC)'
ERROR := @bash -c 'printf $(RED); echo "ERROR: $$0"; printf $(NC); exit 1'
