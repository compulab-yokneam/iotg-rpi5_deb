#! /bin/bash

[[ -z ${IOTG_LIB_HOME} ]] && export IOTG_LIB_HOME=$(dirname $(readlink -e ${BASH_SOURCE[0]}))

# Common lib
. ${IOTG_LIB_HOME}/common.inc
# Stack Lib
. ${IOTG_LIB_HOME}/stack_lib.sh

export DELIM_LINE="+-------"

function slot_show() {
	local fslot=${1:-${BIDX}}								# 1-st slot
	local tslot=${2:-${EIDX}}								# Last slot
	local cslot=$((${tslot} - ${fslot} + 1))				# Number of slots

	# Output stack state as a table
	printf "\n"
	# Header - delimiter
	printf "${DELIM_LINE}" ; printf -- "${DELIM_LINE}%.0s" ${STACK_SLOTS[@]:${fslot}:${cslot}} ; printf "+\n";
	# Header - data - slot indexes
	printf "| %-6s" "Slot" ; printf "|   %-4s"  ${STACK_SLOTS[@]:${fslot}:${cslot}} ; printf  "|\n";
	# Intermediate - delimiter
	printf "${DELIM_LINE}" ; printf -- "${DELIM_LINE}%.0s" ${STACK_SLOTS[@]:${fslot}:${cslot}} ; printf "+\n";
	# Intermediate - data
	printf "| %-6s" "IE" ; printf "| %-6s" ${IE_DETECTED[@]:${fslot}:${cslot}} ; printf "|\n";
	# Footer - delimiter
	printf "${DELIM_LINE}" ; printf -- "${DELIM_LINE}%.0s" ${IE_DETECTED[@]:${fslot}:${cslot}} ; printf "+\n";
	printf "\n"
}


function do_slot() {
	local SLOT=
	PS3="Select Virtual Slot: "
	select s in ${STACK_SLOTS[@]} "<-"; do
		case ${s} in
		"<-")
			return 0
			;;
		'')
			echo Select a correct Slot from the list >&2
			continue
			;;
		*)
			SLOT=${STACK_SLOTS2IDX[${s}]}
			break
			;;
		esac
	done
	command -v slot_${1} &>/dev/null && (slot_${1} ${SLOT} ${SLOT} || true) || do_dummy "slot_${1}"
}

function stack_info_frontplane() {
	[[ -n ${1} ]] && echo "${1}"
	echo ""
	LC_CTYPE=C tree --noreport ${FPE_HOME}
	echo ""
}

function stack_info() {
	stack_info_frontplane "Stack Access Info:"
}

#############################################################################
# stack_manage
#############################################################################
function stack_manage() {
	stack_probe_silent
	stack_manage_config
	stack_manage_access
}

#############################################################################
# Wrapper for "stack" cmd's
#############################################################################
function do_stack() {
	command -v stack_${1} &>/dev/null && (stack_${1} || true) || do_dummy "stack_${1}"
}

### Main

# redirect console log to file
LOG_FILE_NAME=${LOG_FILE_NAME:-${LOGS_HOME}/${IOTG}.stack.log.$(date +${TIMESTAMP_FORMAT})}
mkdir -p ${LOGS_HOME}

opt=${1:-"source"}
param=${2:-}

case ${opt} in
	"stack")
		do_stack ${param}
		;;
	"slot")
		do_slot ${param}
		;;
	"config")
		# Ad-hoc option for automated service
		stack_probe > ${LOG_FILE_NAME}
		stack_manage_access >> ${LOG_FILE_NAME}
		stack_info_frontplane "Stack Access Info:" >> ${LOG_FILE_NAME}
		;;
	"source")
		# Dummy option - applied when file is sourced by external script for further usage
		;;
	*)
		do_dummy $@
		;;
esac
