function get_device() {
	[[ -e /proc/device-tree/cl-model ]] && device=$(tr -d '\0' < /proc/device-tree/cl-model | cut -d" " -f2 | tr '[:upper:]' '[:lower:]') || device=iot-gate-rpi5
	echo ${device}
}

[[ -z "${IOTG}" ]] && export IOTG=$(get_device)

export CM5_MODEL="rpi5"
export CM5_LITE_MODEL="rpi5l"
export CM5_DEFAULT_MODEL="${CM5_LITE_MODEL}"

function get_cm5_model() {
	# Extract the Revision value
	REV_HEX=$(grep -i "^Revision" /proc/cpuinfo | cut -d':' -f2 | tr -d ' ')
	if [ -z "$REV_HEX" ]; then
		echo "${CM5_DEFAULT_MODEL}"
		return 1
	fi
	# Convert hex value to dec
	REV_DEC=$((16#$REV_HEX))
	# Extract the Type Code
	TYPE_CODE=$(( (REV_DEC >> 4) & 0xFF ))
	# Check the Type Code
	case ${TYPE_CODE} in
		24)
			# 0x18 - CM5
			echo "${CM5_MODEL}"
			;;
		26)
			# 0x1A - CM5 Lite
			echo "${CM5_LITE_MODEL}"
			;;
		*)
			echo "${CM5_DEFAULT_MODEL}"
			return 1
			;;
	esac
	return 0
}

[[ -z "${RPI_MODEL}" ]] && export RPI_MODEL=$(get_cm5_model)

# LOGs stuff
export LOGS_HOME=/run/${IOTG}/log
TIMESTAMP_FORMAT="%Y%m%d_%H%M%S"

# Genaral stuff
export DUMMY_PATH=/dev/null
export I2C_BUS=/sys/bus/i2c/devices
export IIO_BUS=/sys/bus/iio/devices
export USB_BUS=/sys/bus/usb/devices

# CONFIG modification stuff - taken from raspi-config

################################################################
# set_config_var() - set a new value for a variable in a configuration file
# The file is expected to contain lines in the form:
#   <key>=<value>
# A line starting with '#' is assumed to be a comment
# @key - variable to set
# @value - new value to assign
# @file - configuration file to modify
################################################################
set_config_var() {
  awk -v key="$1" -v value="$2" '
    $0 ~ "^#?[[:space:]]*" key "=" {
      print key "=" value
      made_change=1
      next
    }
    { print }
    END { if (!made_change) print key "=" value }
  ' "$3" > "$3.bak" && mv "$3.bak" "$3"
}

################################################################
# clear_config_var() - clear (comment out) a variable in a configuration file
# @key - variable to clear
# @file - configuration file to modify
################################################################
clear_config_var() {
  sed -i "s/^\([[:space:]]*$1=\)/#\1/" "$2"
}

################################################################
# get_config_var() - get the value of a variable from a configuration file
# @key - variable to look up
# @file - configuration file to look up in
################################################################
get_config_var() {
  awk -v key="$1" '
    $0 ~ "^[[:space:]]*" key "=" {
      sub("^[[:space:]]*" key "=", "")
      print
      found=1
      exit
    }
    END { if (!found) print 0 }
  ' "$2"
}
