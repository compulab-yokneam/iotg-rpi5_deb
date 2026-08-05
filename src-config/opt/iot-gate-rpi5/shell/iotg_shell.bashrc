function get_device() {
	[[ -e /proc/device-tree/cl-model ]] && device=$(tr -d '\0' < /proc/device-tree/cl-model | cut -d" " -f2 | tr '[:upper:]' '[:lower:]') || device=iot-gate-rpi5
	echo ${device}
}


export IOTG=$(get_device)

IOTG_SHELL_HOME=/opt/${IOTG}/shell
STACK_LIB=${IOTG_SHELL_HOME}/stack.sh

do_iotg() {
	${STACK_LIB} $@
}

GW_LIB=${IOTG_SHELL_HOME}/gw.sh

do_gateway() {
	${GW_LIB} $@
}
usage () {
cat << eof
~~~~ Explore and Manage
[Ss] - Explore I/O Stack: probe and display (all I/O slots)
[Vv] - Explore I/O Slot: probe and display (specific I/O slot)
[Mm] - Manage I/O Stack: validate configuration and grant access (all I/O slots)
[Ww] - Manage Gateway: validate configuration and grant access
~~~~ Show Info
[Ii] - Show I/O Stack Info (I/O slots only)
[Gg] - Show Gateway Info (Gateway only)
[Ff] - Show Full Info (Gateway + all I/O slots)
~~~~ Misc
[Qq] - Quit IOTG shell
eof
}

PS1='$(usage)\n\nIOTG shell ( device: ${IOTG} ) > '
set -m

alias s='do_iotg stack probe'
alias S='do_iotg stack probe'
alias v='do_iotg slot probe'
alias V='do_iotg slot probe'
alias m='do_iotg stack manage'
alias M='do_iotg stack manage'
alias i='do_iotg stack info'
alias I='do_iotg stack info'
alias w='do_gateway manage'
alias W='do_gateway manage'
alias g='do_gateway info'
alias G='do_gateway info'
alias f='do_gateway info ; do_iotg stack info'
alias F='do_gateway info ; do_iotg stack info'
alias q='exit'
alias Q='exit'
alias exit='exit'
alias quit='exit'
