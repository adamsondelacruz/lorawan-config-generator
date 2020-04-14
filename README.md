# AMIGO GATEWAY
![version][version-badge]

## Overview
This repository contains information on how to install the amigo gateway into your raspberry-pi

## Hardware Requirements
- amigo usb gateway
- raspberry pi v3 or higher

## Software Requirements
- raspian os
- gnumake (comes pre-installed )
- git


## INSTALL AMIGO
```
sudo apt-get update -y && sudo apt-get install git -y
git clone https://github.com/adamsondelacruz/lorawan-config-generator.git
cd lorawan-config-generator && make all
```

## GENERATE THE GATEWAY-ID
This is a one-off command. Make sure that the amigo is inserted on the raspberry pi USB port
```
make gateway-id
```

## GENERATE CONFIGURATION
It is important that before you start the gateway, this command has been run at least once.
```
make generate
```

## START GATEWAY
Starts the amigo gateway
```
make start
```

#### If you have questions, contact:
```
Adamson dela Cruz
CEO/CTO
IOT NINJA LIMITED
Work Email       : adam@theiotninja.com
Personal Email   : adamson.delacruz@gmail.com

```
