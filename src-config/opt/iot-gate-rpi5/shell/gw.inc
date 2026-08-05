
# GW home 
export GW_HOME=/run/${IOTG}/gateway
export GW_ACCESS=${GW_HOME}/access

## Connectivity/Network
export GW_ACCESS_NET=${GW_ACCESS}/network
### WiFI/BT
export GW_ACCESS_WLAN=wlan
export GW_ACCESS_BT=bluetooth
export GW_WIFI_HOME=/sys/class/net
export GW_WIFI_DEV_HOME=/sys/bus/mmc/devices/mmc1:0001/mmc1:0001:1/net
export GW_BT_HOME=/sys/class/bluetooth
export GW_BT_DEV_HOME=/sys/bus/serial/devices/serial0-0/bluetooth
### MESH
export ACCESS_TTY=tty
export GW_MESH_TTY=ttyMesh
export GW_MESH_TYPE=type
export GW_ACCESS_MESH_HOME=${GW_ACCESS_NET}/mesh
export MESH_USB_HOME=${USB_BUS}/4-1/4-1.3
export MESH_USB_DEV=${MESH_USB_HOME}/4-1.3:1.0
export MESH_DEV_HOME=${MESH_USB_HOME}/4-1.3:1.0/tty
export MESH_DEVID_HOME=${MESH_USB_HOME}
export IDVENDOR=idVendor
export IDPROD=idProduct
declare -a MESH_SUBTYPE=("NORD")
declare -A MESH_USB_IDVENDOR=(
		[NORD]="37a1"
)
declare -A MESH_USB_IDPROD=(
		[NORD]="0101"
)
declare -A GW_ACCESS_MESH=(
		[NORD]=${ACCESS_TTY}
)

### Modem
export GW_ACCESS_MODEM_HOME=${GW_ACCESS_NET}/modem
export GW_MODEM_TTY=ttyModem
export GW_MODEM_AT1=at1
export GW_MODEM_AT2=at2
export GW_MODEM_QCDM=qcdm
export GW_MODEM_GPS=gps

export CELL_USB_HOME=${USB_BUS}/4-1/4-1.2
export CELL_DEVID_HOME=${CELL_USB_HOME}
export CELL_SYSPATH=${CELL_USB_HOME}
declare -a CELL_TYPE=("T910G")
declare -A CELL_USB_IDVENDOR=(
		[T910G]="1bc7"
)
declare -A CELL_USB_IDPROD=(
		[T910G]="1031"
)

## LEDs
export GW_ACCESS_LED_HOME=${GW_ACCESS}/leds
export LED_HOME=/sys/class/leds
declare -a GW_ULED_ARR=("A")
export GW_LED_RED=red
export GW_LED_GREEN=green
declare -a GW_ULED_COLOR=("${GW_LED_RED}" "${GW_LED_GREEN}")
export LED_TRG_PTRN_MOD=ledtrig_pattern

## CMD button
export GW_ACCESS_CMD_BTN_HOME=${GW_ACCESS}/cmd_button
export GW_ACCESS_CMD_BTN=event
export GW_CMD_BTN_DEV=/dev/input/by-path/platform-gpio-keys-event

## TPM
export GW_ACCESS_TPM_HOME=${GW_ACCESS}/tpm
export GW_ACCESS_TPM=tpm
export GW_ACCESS_TPMRM=tpmrm
export TPM_DEV_BASE=/sys/bus/i2c/devices/3-002e
export TPM_DEV_HOME=${TPM_DEV_BASE}/tpm
export TPMRM_DEV_HOME=${TPM_DEV_BASE}/tpmrm
export TPM_HOME=/sys/class/tpm
export TPMRM_HOME=/sys/class/tpmrm

## PCI
export GW_PCI_DEV_HOME=/sys/bus/pci/devices/0001:00:00.0/0001:01:00.0
export PCI_VENDOR=vendor
export PCI_DEV=device

declare -a AI_SUBTYPE=("HL")
declare -A AI_PCI_IDVENDOR=(
		[HL]="0x1e60"
)
declare -A AI_PCI_IDPROD=(
		[HL]="0x2864"
)

## Block devices
export GW_ACCESS_BLKDEV_HOME=${GW_ACCESS}/blkdev
export GW_ACCESS_EMMC=emmc
export GW_EMMC_DEV=mmcblk0
export GW_EMMC_DEV_HOME=/dev
export GW_EMMC_SYSPATH=/sys/bus/mmc/devices/mmc0:0001/block
export GW_ACCESS_NVME=nvme
export GW_NVME_DEV=nvme0n1
export GW_NVME_DEV_HOME=/dev
export GW_NVME_SYSPATH=${GW_PCI_DEV_HOME}/nvme
