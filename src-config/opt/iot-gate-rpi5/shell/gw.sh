#! /bin/bash

[[ -z ${IOTG_LIB_HOME} ]] && export IOTG_LIB_HOME=$(dirname $(readlink -e ${BASH_SOURCE[0]}))

# Includes
. ${IOTG_LIB_HOME}/common.inc
. ${IOTG_LIB_HOME}/gw.inc

function gw_info_frontplane() {
	[[ -n ${1} ]] && echo "${1}"
	echo ""
	LC_CTYPE=C tree --noreport ${GW_ACCESS}
	echo ""
}

function gw_grant_access() {
	# Make GW assess homedir
	local access_home=${GW_ACCESS}
	rm -rf ${access_home}
	mkdir -p ${access_home}

	# Connectivity/Network
	mkdir -p ${GW_ACCESS_NET}
	## WiFi/BT
	if [[ -d ${GW_WIFI_DEV_HOME} ]]; then
		local wlan=$(ls ${GW_WIFI_DEV_HOME})
		[[ -L ${GW_WIFI_HOME}/${wlan} ]] && ln -s ${GW_WIFI_HOME}/${wlan} ${GW_ACCESS_NET}/${GW_ACCESS_WLAN}
	fi
	if [[ -d ${GW_BT_DEV_HOME} ]]; then
		local bt=$(ls ${GW_BT_DEV_HOME})
		[[ -L ${GW_BT_HOME}/${bt} ]] && ln -s ${GW_BT_HOME}/${bt} ${GW_ACCESS_NET}/${GW_ACCESS_BT}
	fi

	## Modem
	mkdir -p ${GW_ACCESS_MODEM_HOME}
	[[ -L /dev/${GW_MODEM_TTY}${GW_MODEM_AT1^^} ]]  && ln -s /dev/${GW_MODEM_TTY}${GW_MODEM_AT1^^} ${GW_ACCESS_MODEM_HOME}/${GW_MODEM_AT1}
	[[ -L /dev/${GW_MODEM_TTY}${GW_MODEM_AT2^^} ]]  && ln -s /dev/${GW_MODEM_TTY}${GW_MODEM_AT2^^} ${GW_ACCESS_MODEM_HOME}/${GW_MODEM_AT2}
	#[[ -L /dev/${GW_MODEM_TTY}${GW_MODEM_GPS^^} ]]  && ln -s /dev/${GW_MODEM_TTY}${GW_MODEM_GPS^^} ${GW_ACCESS_MODEM_HOME}/${GW_MODEM_GPS}
	[[ -L /dev/${GW_MODEM_TTY}${GW_MODEM_QCDM^^} ]] && ln -s /dev/${GW_MODEM_TTY}${GW_MODEM_QCDM^^} ${GW_ACCESS_MODEM_HOME}/${GW_MODEM_QCDM}

	## MESH
	mkdir -p ${GW_ACCESS_MESH_HOME}
	local tty=$(readlink -e /dev/${GW_MESH_TTY})
	# Grant access if detected
	if [[ -n ${tty} ]] ; then
		# Detect subtype
		local idvendor=$(cat ${MESH_DEVID_HOME}/${IDVENDOR})
		local idprod=$(cat ${MESH_DEVID_HOME}/${IDPROD})
		for s in ${MESH_SUBTYPE[@]} ; do
			if [[ "${idvendor,,}" == ${MESH_USB_IDVENDOR[${s}]} ]] ; then
				if [[ "${idprod,,}" == ${MESH_USB_IDPROD[${s}]} ]] ; then
					touch ${GW_ACCESS_MESH_HOME}/${GW_MESH_TYPE}.${s}
					ln -s /dev/${GW_MESH_TTY} ${GW_ACCESS_MESH_HOME}/${GW_ACCESS_MESH[${s}]}
					break
				fi
			fi
		done
	fi

	# LEDs
	mkdir -p ${GW_ACCESS_LED_HOME}
	for led in ${GW_ULED_ARR[@]} ; do
		for color in ${GW_ULED_COLOR[@]} ; do
			[[ -L ${LED_HOME}/${color^}"_"${led} ]]  && ln -s ${LED_HOME}/${color^}"_"${led} ${GW_ACCESS_LED_HOME}/${color}"_"${led,,}
		done
	done

	# CMD Button
	mkdir -p ${GW_ACCESS_CMD_BTN_HOME}
	[[ -L ${GW_CMD_BTN_DEV} ]] && ln -s $(readlink -f ${GW_CMD_BTN_DEV}) ${GW_ACCESS_CMD_BTN_HOME}/${GW_ACCESS_CMD_BTN}

	# TPM
	mkdir -p ${GW_ACCESS_TPM_HOME}
	if [[ -d ${TPM_DEV_HOME} ]]; then
		local tpm=$(ls ${TPM_DEV_HOME})
		[[ -L ${TPM_HOME}/${tpm} ]] && ln -s ${TPM_HOME}/${tpm} ${GW_ACCESS_TPM_HOME}/${GW_ACCESS_TPM}
	fi
	if [[ -d ${TPMRM_DEV_HOME} ]]; then
		local tpmrm=$(ls ${TPMRM_DEV_HOME})
		[[ -L ${TPMRM_HOME}/${tpmrm} ]] && ln -s ${TPMRM_HOME}/${tpmrm} ${GW_ACCESS_TPM_HOME}/${GW_ACCESS_TPMRM}
	fi

	# Block devices
	mkdir -p ${GW_ACCESS_BLKDEV_HOME}
	## NVME
	local nvme=${GW_NVME_DEV_HOME}/${GW_NVME_DEV}
	if [[ -b ${nvme} ]]; then
		ln -s ${nvme} ${GW_ACCESS_BLKDEV_HOME}/${GW_ACCESS_NVME}
	fi
	## eMMC
	local emmc=${GW_EMMC_DEV_HOME}/${GW_EMMC_DEV}
	if [[ -b ${emmc} ]]; then
		ln -s ${emmc} ${GW_ACCESS_BLKDEV_HOME}/${GW_ACCESS_EMMC}
	fi
}

### Main

LOG_FILE_NAME=${LOG_FILE_NAME:-${LOGS_HOME}/${IOTG}.gw.log.$(date +${TIMESTAMP_FORMAT})}
mkdir -p ${LOGS_HOME}

opt=${1:-"source"}
param=${2:-}

case ${opt} in
	"config")
		# Ad-hoc option for automated service
		gw_grant_access ${param} > ${LOG_FILE_NAME}
		gw_info_frontplane "Gateway Access Info:" >> ${LOG_FILE_NAME}
		;;
	"info")
		gw_info_frontplane "Gateway Access Info:"
		;;
	"manage")
		gw_grant_access
		;;
	"source")
		# Dummy option - applied when file is sourced by external script for further usage
		;;
	*)
		;;
esac
