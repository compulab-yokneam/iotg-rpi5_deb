#! /bin/bash

# Stack Lib
. ${IOTG_LIB_HOME}/stack_lib.inc

#############################################################################
# int detect_ie_type() - derives an IE board type for a given slot
# @slot - slot name A, B, C
# A detected IE type is set in the IE_DETECTED[] array
#############################################################################
function detect_ie_type() {
	local slot=${1:-}
	[[ ! -z ${slot} ]] || return 1;
	[[ "${STACK_SLOTS[@]}" =~ ${slot} ]] || return 1;
	local idx=${STACK_SLOTS2IDX[${slot}]}
	local ie_type="${IE_TYPE_ND}"

	# Extract the configuration line for the specific slot
	local ie_cfg=$(grep -m 1 -i "^[[:space:]]*""${IE_SLOT_CFG}${slot,,}" "${CL_CONFIG}")
	if [[ -n ${ie_cfg} ]] ; then
		# Extract the 'type' (everything between '=' and the first ',' or end of line)
		# Using sed to grab the string after '=' but before any ','
		ie_type=$(echo "${ie_cfg}" | sed 's/.*=//; s/,.*//')
		case ${slot} in
		"A" | "B")
			[[ -z ${ie_type^^} ]] && ie_type=${IE_TYPE_ND}
			[[ "${IE_SUPPORTED[${s}]}" =~ "${ie_type^^}" ]] || ie_type=${IE_TYPE_ND}
			IE_DETECTED[${idx}]="${ie_type^^}"
			IE_CONFIG[${idx}]=${IE_DETECTED[${idx}]}
			;;
		"C")
			# The permanent DIO block can be treated as a slot "C" that is always populated with the IE-DIO module
			IE_DETECTED[${idx}]=${IE_DIO}
			IE_CONFIG[${idx}]=${IE_DIO}
			# Use default settings if no explicit configuration is found
			[[ "${ie_type^^}" == "${IE_DIO}" ]] || return 0
			# Parse slot "C" parameters - output list
			for token in $(echo "${ie_cfg}" | tr '=,' ' '); do
				case ${token} in
				o[0-3])
					i=${token#o} # Strip the 'o' to get the digit
					# Set the output bitmap for the selected pin, reset the input bitmap
					DO_CMAP[${i}]=${DIO_VAL}
					DI_CMAP[${i}]=${DIO_INV}
					;;
				io[0-3])
					i=${token#io} # Strip the 'io' to get the digit
					# Set the output and the input bitmaps for the selected pin, reset the input bitmap
					DO_CMAP[${i}]=${DIO_VAL}
					DI_CMAP[${i}]=${DIO_VAL}
					;;
				esac
			done
			;;
		esac
	else
		[[ "${slot}" == "${IE_DIO_SLOT}" ]] || return 0
		# Slot C: use default settings if no explicit configuration is found
	fi

	return 0
}

#############################################################################
# int get_ie_type() - determines IE board type for a given slot
# @slot - slot name A, B, C
# A detected IE type is set in the IE_DETECTED[] array
#############################################################################
function get_ie_type() {
	local slot=${1:-}
	[[ ! -z ${slot} ]] || return 1;

	[[ "${STACK_SLOTS[@]}" =~ ${slot} ]] && detect_ie_type ${slot} || return 1
	[[ "${slot}" == "${IE_DIO_SLOT}" ]] || return 0
	#echo "Slot ${slot}: DO_CMAP=(${DO_CMAP[@]}), DI_CMAP=(${DI_CMAP[@]})"

	return $?
}

function slot_probe() {
	local fslot=${1:-${BIDX}}	# From slot
	local tslot=${2:-${EIDX}}	# To slot
	local slot_list=$(seq ${fslot} ${tslot})
	local verbose=${3:-1}

	# Loop over all requested slots
	for i in ${slot_list}; do
		s=${STACK_SLOTS[${i}]^^}
		get_ie_type ${s}
	done

	if [[ ${verbose} -eq 1 ]]; then
		# Display stack
		slot_show ${fslot} ${tslot} 
	fi
}


function ie_grant_access() {
	# Slot index
	local idx=${1}	
	# Validate slot index
	[[ ${idx} -lt ${EIDX} || ${idx} -gt ${BIDX} ]] || return 1;
	local slot=${STACK_SLOTS[${idx}]}
	local ie_type=${IE_DETECTED[${idx}]}
	local ie_home=${FPE_HOME}/${STACK_SLOTS[${idx}]}/${IE_ACCESS}
	# create access subdir
	rm -rf ${ie_home} ; mkdir -p ${ie_home}

	case ${ie_type} in
		"${IE_TYPE_INV}"|"${IE_TYPE_ND}")
			# Nothing to do
			rm -rf ${ie_home}
			return 0
			;;
		"${IE_RS485}"|"${IE_COMBO}")
			local tty=$(readlink -e /dev/${TTY_IE}${slot})
			[[ -n ${tty} ]] && ln -s ${tty} ${ie_home}/${ACCESS_TTY}
			;;&
		"${IE_CAN}"|"${IE_COMBO}")
			local can_dev_home=${CAN_DEV_HOME[${slot}]}
			if [[ -d ${can_dev_home} ]]; then
				local can=$(ls ${can_dev_home})
				[[ -L ${CAN_HOME}/${can} ]] && ln -s ${CAN_HOME}/${can} ${ie_home}/${ACCESS_CAN}
			fi
			;;
		"${IE_DIO}")
			local len=${#DO_CMAP[@]}
			# Mask unused pins
			for (( i=0; i<len; i++ )) ; do
				[[ ${CHIP_I[${i}]} -ne ${DIO_INV} ]] && ci[i]=$(( CHIP_I[i] | DI_CMAP[i] )) || ci[i]=${DIO_INV}
				[[ ${CHIP_I[${i}]} -ne ${DIO_INV} ]] && pi[i]=$(( PIN_I[i]  | DI_CMAP[i] )) || pi[i]=${DIO_INV}
				[[ ${CHIP_O[${i}]} -ne ${DIO_INV} ]] && co[i]=$(( CHIP_O[i] | DO_CMAP[i] )) || co[i]=${DIO_INV}
				[[ ${CHIP_O[${i}]} -ne ${DIO_INV} ]] && po[i]=$(( PIN_O[i]  | DO_CMAP[i] )) || po[i]=${DIO_INV}
			done
			echo ${ci[@]} > ${ie_home}/${ACCESS_DI}
			echo ${pi[@]} >> ${ie_home}/${ACCESS_DI}
			echo ${co[@]} > ${ie_home}/${ACCESS_DO}
			echo ${po[@]} >> ${ie_home}/${ACCESS_DO}
			;;
		*)
			return 0
			;;
	esac

}

function ie_add() {
	# Slot index
	local idx=${1}	
	# Validate slot index
	[[ ${idx} -lt ${EIDX} || ${idx} -gt ${BIDX} ]] || return 1;
	local ie_type=${IE_DETECTED[${idx}]}

	# Create IFM home directory
	local ie_home=${FPE_HOME}/${STACK_SLOTS[${idx}]}
	rm -rf ${ie_home} # Check if somewhat needed
	mkdir -p ${ie_home}

	## Specify detected IFM type 
	rm -rf ${ie_home}/${IE_TYPE}.*
	touch ${ie_home}/${IE_TYPE}.${ie_type}
	# populate with access info according to IE type
	ie_grant_access ${idx}
}


#############################################################################
# Grant access: populate the Stack frotnplane access directory
#############################################################################
function stack_manage_access() {
	local fslot=${BIDX}	# From slot
	local tslot=${EIDX}	# To slot
	local slot_list=$(seq ${fslot} ${tslot})
	local ret=

	for i in ${slot_list}; do
		ie_add ${i} ; (( ret |= 1 ))
	done
	return ${ret}
}

#############################################################################
# Validate stack, return 0 if contains a valid and fully accessable set
# or 1 otherwise
#############################################################################
function stack_manage_config() {
	local local verbose=${1:-1}
	local fslot=${BIDX}	# From slot
	local tslot=${EIDX}	# To slot
	local slot_list=$(seq ${fslot} ${tslot})
	aslot=() # Accessible slots
	islot=() # Invalid slots
	eslot=() # Empty slots
	local ret=

	for i in ${slot_list}; do
		s=${STACK_SLOTS[${i}]}
		if [[ "${IE_DETECTED[${i}]}" == "${IE_TYPE_ND}" ]] ; then
			# No IE module was detected - the slot is considered empty
			eslot+=("${s}")
			continue
		fi
		if [[ "${IE_DETECTED[${i}]}" ==  "${IE_TYPE_INV}" ]] ; then
			# Unknown IE type
			islot+=("${s}")
			continue
		fi
		if [[ "${IE_SUPPORTED[${s}]}" =~ "${IE_DETECTED[${i}]}" ]] ; then
			# The detected IE module is compatible with the current slot
			aslot+=("${s}")
			continue
		else
			# The detected IE module is incompatible with the current slot
			islot+=("${s}")
			IE_DETECTED[${i}]=${IE_TYPE_INV}
			continue
		fi
	done

	local cutline="###############################################################"
	printf "\n%s\n" ${cutline}
	printf "Valid and accessable slots: " ; [[ ${#aslot[@]} == 0 ]] || printf "[%s] " ${aslot[@]}
	printf "\nInaccessable slots:\n"
	printf "  Invalid: " ; [[ ${#islot[@]} == 0 ]] || printf "{%s} " ${islot[@]}
	printf "\n  Empty:   " ; [[ ${#eslot[@]} == 0 ]] || printf "(%s) " ${eslot[@]}
	printf "\n%s\n" ${cutline}
	return 0
}

#############################################################################
# Probe and display all slots
#############################################################################
function stack_probe() {
	slot_probe
}

function stack_probe_silent() {
	slot_probe ${BIDX} ${EIDX} 0
}
