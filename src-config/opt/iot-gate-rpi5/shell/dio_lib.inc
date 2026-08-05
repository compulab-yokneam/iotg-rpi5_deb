LIBGPIOD_OPT=

function msg() {
	echo "${SCR_NAME}: $@"
}

function err_msg() {
	msg "Error: $@"
	exit 1
}

function check_params() {
	local inout=${1}
	local slot=${2:-}
	local offset=${3:-}
	local dmap=
	local d_num=
	local location=

	if [[ "${slot^^}" == "${IE_DIO_SLOT}" ]] ; then
#		. ${IOTG_LIB_HOME}/stack_lib.inc
		location="I/O Stack Slot ${slot^^}"
		local slot_home=${FPE_HOME}/${slot^^}
		[[ -d ${slot_home} ]] || err_msg "No DIO module detected in the ${location}"
		local ie_type=$(ls ${slot_home} | grep "${IE_TYPE}\.")
		ie_type="${ie_type##*.}"
		[[ "${ie_type}" == "${IE_DIO}" ]] || err_msg "No DIO module detected in the ${location}"
		if [[ "${inout}" == "in" ]] ; then
			dmap=${slot_home}/${IE_ACCESS}/${ACCESS_DI}
		else
			dmap=${slot_home}/${IE_ACCESS}/${ACCESS_DO}
		fi
	fi

	[[ -e ${dmap} ]] || err_msg "Issue detected with DIO module in the ${location}"
	{ read -a D_CHIP ; read -a D_PIN ; } <${dmap}
	d_num=${#D_CHIP[@]}
	[[ ${d_num} -ge 0 ]] || err_msg "Issue detected with DIO module in the ${location}"
	[[ ${offset} -ge 0 && ${offset} -lt ${d_num} ]] || err_msg "Invalid pin offset '${offset}'"
	[[ ${D_CHIP[${offset}]} -eq  ${DIO_INV} || ${D_PIN[${offset}]} -eq  ${DIO_INV} ]] && err_msg "Invalid pin offset '${offset}'"

	# Check libgpiod version and set additional options if required
	local gpioutil=gpioset
	if [[ "${inout}" == "in" ]] ; then
		gpioutil=gpioget
	fi
	libgpiod_version=$(${gpioutil} -v 2>/dev/null | awk '/ \(libgpiod\) v/ {print $NF}')
	if [[ ${libgpiod_version} =~ v(2\.[0-9]+\.[0-9]+) ]] ; then
		if [[ "${inout}" == "in" ]] ; then
			# Add options for gpioget
			local GPIOGET_OPT="--numeric" # old style output (value only)
			LIBGPIOD_OPT=${GPIOGET_OPT}
		else
			# Add options for gpioset
			local GPIOSET_OPT="--toggle 0" # return immediately
			LIBGPIOD_OPT=${GPIOSET_OPT}
		fi
		# Add common options
		LIBGPIOD_OPT=${LIBGPIOD_OPT}" --chip"
	fi
}

function check_params_out() {
	local slot=${1:-}
	local offset=${2:-}

	check_params "out" ${1} ${2}
}

function check_params_in() {
	local slot=${1:-}
	local offset=${2:-}

	check_params "in" ${1} ${2}
}
