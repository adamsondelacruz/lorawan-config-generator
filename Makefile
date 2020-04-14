# Project settings
-include .env
PROJECT_NAME = amigo-rpi
HOME_DIR ?=amigo
TEMPLATE ?=AS2
PORT_UP ?=1700
PORT_DOWN ?=1700
NETWORK_SERVER ?=dev.ttn.iotninja.io
FILE_EXISTS := $(or $(and $(wildcard ~/$(HOME_DIR)/.gatewayid),1),0)
GATEWAY_ID ?=0000000000000000
export

all: install-gw install-dfu compile-hal generate
	${INFO} "Done !!! Amigo Gateway is now ready..."	

init:
	${INFO} "Creating Home Directory ~/${HOME_DIR}"
	mkdir -p ~/${HOME_DIR}	

install-gw: init
	${INFO} "Updating package..."
	sudo apt-get update -y
	${INFO} "INSTALLING Gateway..."
	cd ~/${HOME_DIR} && \
	git clone https://github.com/adamsondelacruz/picoGW_packet_forwarder.git && \
	git clone https://github.com/adamsondelacruz/picoGW_mcu.git && \
	git clone https://github.com/adamsondelacruz/picoGW_hal.git
	${INFO} "Done !!!"

install-dfu:
	${INFO} "Installing dfu..."
	sudo apt-get install autoconf -y 
	cd ~/${HOME_DIR} && \
	git clone https://github.com/adamsondelacruz/dfu-util && \
	cd dfu-util && \
	./autogen.sh && \
	sudo apt-get install libusb-1.0-0-dev -y && \
	./configure && make && sudo make install
	${INFO} "Done !!!"

compile-hal:
	${INFO} "Installing HAL..."
	cd ~/${HOME_DIR}/picoGW_hal	&& make clean all
	cd ~/${HOME_DIR}/picoGW_packet_forwarder && make clean all
	${INFO} "Done !!!"

gateway-id:
	${INFO} "Getting gatewayId ~/${HOME_DIR}"	
ifeq ($(FILE_EXISTS), 1)
	@cat ~/${HOME_DIR}/.gatewayid
else
	cd ~/${HOME_DIR}/picoGW_hal/util_chip_id && \
	./util_chip_id -d /dev/ttyACM0 > ~/${HOME_DIR}/.gatewayid
endif
	$(eval GATEWAY_ID=$(shell cat ~/${HOME_DIR}/.gatewayid))
	
generate: gateway-id
	${INFO} "Generating global_conf.json"
	mkdir -p ~/${HOME_DIR}
	sed -e 's/{{NETWORK_SERVER}}/${NETWORK_SERVER}/' \
		-e 's/{{PORT_UP}}/${PORT_UP}/' \
		-e 's/{{GATEWAY_ID}}/${GATEWAY_ID}/' \
		-e 's/{{PORT_DOWN}}/${PORT_DOWN}/' <templates/frequency_plan/${TEMPLATE}-global_conf.json>~/${HOME_DIR}/picoGW_packet_forwarder/lora_pkt_fwd/global_conf.json
		# -e 's/{{PORT_DOWN}}/${PORT_DOWN}/' <templates/frequency_plan/${TEMPLATE}-global_conf.json>~/${HOME_DIR}/global_conf.json
		
	${INFO} "Done !!!"

start:
	${INFO} "Starting the Amigo Gateway...."
	cd ~/${HOME_DIR}/picoGW_packet_forwarder/lora_pkt_fwd && ./lora_pkt_fwd

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
