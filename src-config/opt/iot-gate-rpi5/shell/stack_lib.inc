# I/O extension home
export IO_STACK_HOME=/run/${IOTG}/io_stack
## Frontplane Emulation home
export FPE_HOME=${IO_STACK_HOME}/frontplane
export IE_TYPE=type
export IE_SUBTYPE=subtype
export IE_ACCESS=access
export ACCESS_TTY=tty
export ACCESS_CAN=can
export ACCESS_GPIO=gpiochip
export ACCESS_DI=di.map
export ACCESS_DO=do.map

## IE Types

### RS485
export IE_RS485="RS485"
export TTY_IE=ttyRS485_


### CAN
export IE_CAN="CAN"
export CAN_DEV_HOME=/sys/bus/spi/devices
export CAN_HOME=/sys/class/net
declare -A CAN_DEV_HOME=(
		[A]=${CAN_DEV_HOME}/spi2.0/net
		[B]=${CAN_DEV_HOME}/spi0.0/net
)


### DIO
export IE_DIO="DIO"
declare -a CHIP_O=(14 14 14 14)
declare -a PIN_O=(0 1 2 3)
declare -a CHIP_I=(0 0 0 0)
declare -a PIN_I=(6 19 25 27)
### 1-st DIO pin index: 'B' for begin
export BDIO=0
### Last DIO pin index: 'E' for end
export EDIO=3


## Slot stuff
### 1-st slot index: 'B' for begin
export BIDX=0
### Last slot index: 'E' for end
export EIDX=2

### Slots array: array index -> slot's index
declare -a STACK_SLOTS=("A" "B" "C")

### Slot name-to-index translation array: name -> key, value -> index
declare -A STACK_SLOTS2IDX=(
		[A]=0
		[B]=1
		[C]=2
)

### Unique slots
export IE_DIO_SLOT="C"

## IE detection stuff
export IE_TYPE_INV="Inval"	# Invalid
export IE_TYPE_ND="IDLE"	# Not detected - the slot is assumed to be idle

## Detected IEs
declare -a IE_DETECTED=(
		"${IE_TYPE_ND}"
		"${IE_TYPE_ND}"
		"${IE_DIO}"
)

## IE user cfg stuff
export IE_CONF_DEF="${IE_TYPE_ND}"

## User defined IEs configuration
declare -a IE_CONFIG=(
		"${IE_CONF_DEF}"
		"${IE_CONF_DEF}"
		"${IE_DIO}"
)

## DI / DO maps
export DIO_VAL=0
export DIO_INV=-1
declare -a DI_CMAP=(${DIO_VAL} ${DIO_VAL} ${DIO_VAL} ${DIO_VAL})
declare -a DO_CMAP=(${DIO_INV} ${DIO_INV} ${DIO_INV} ${DIO_INV})

declare -a DI_UMAP=(${DIO_VAL} ${DIO_VAL} ${DIO_VAL} ${DIO_VAL})
declare -a DO_UMAP=(${DIO_INV} ${DIO_INV} ${DIO_INV} ${DIO_INV})

declare -A DIO_VALUE_PRINT=(
		[${DIO_VAL}]="*"
		[${DIO_INV}]=" "
)

## Support map IEs
export IE_COMBO="COMBO"
declare -A IE_SUPPORTED=(
		[A]="${IE_RS485} | ${IE_CAN} | ${IE_COMBO}"
		[B]="${IE_RS485} | ${IE_CAN} | ${IE_COMBO}"
		[C]="${IE_DIO}"
)

## Configuration
export CONFIG_FILE=config.txt
FIRMWARE=
[[ -e /boot/firmware/${CONFIG_FILE} ]] && FIRMWARE=/firmware
export CONFIG_HOME=/boot${FIRMWARE}
export CONFIG=${CONFIG_HOME}/${CONFIG_FILE}
export CONFIG_BAK=${CONFIG}.prev
export CL_CONFIG_FILE=cl-config.txt
export CL_CONFIG=${CONFIG_HOME}/${CL_CONFIG_FILE}
export CL_CONFIG_BAK=${CL_CONFIG}.prev

export IE_SLOT_CFG="ie_"

export NEW_CONFIG=$(mktemp --dry-run -p /tmp config.txt.XXX)
export IOTG_RPI5_CONFIG=$(mktemp --dry-run -p /tmp iotg-rpi5_config.XXX)
export NEW_CL_CONFIG=$(mktemp --dry-run -p /tmp cl_config.XXX)
export IOTG_RPI5_PATTERN="iotg-rpi5"
export IOTG_RPI5_DTB="iotg-${RPI_MODEL}.dtb"
