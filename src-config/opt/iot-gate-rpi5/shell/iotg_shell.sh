#!/bin/bash

# Check user ID
if [[ $(id -u) -ne 0 ]] ; then
	printf "Please run as root: 'sudo ${BASH_SOURCE[0]}'\n";
	exit 1
fi

IOTG_SHELL=$(dirname $(readlink -e ${BASH_SOURCE[0]}))

bash --rcfile ${IOTG_SHELL}/iotg_shell.bashrc
