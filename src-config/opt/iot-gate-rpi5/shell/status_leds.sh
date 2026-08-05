#! /bin/bash

export LED_OK="Blue"
export LED_SOS="Amber"
export PATTERN_OK="1 270 0 90 1 270 0 90 1 270 0 290 1 270 0 90 1 90 0 90 1 270 0 1260"
export PATTERN_SOS="1 90 0 90 1 90 0 90 1 90 0 270 1 270 0 90 1 270 0 90 1 270 0 270 1 90 0 90 1 90 0 90 1 90 0 1260"

export LEDS_HOME=/sys/class/leds

function set_led() {
        local code=${1}
        local led=${2:-''}

        case ${code} in
        "off")
                echo none > ${LEDS_HOME}/PowerLED_${led}/trigger
                return 0
                ;;
        "ok")
                led=${LED_OK}
                ;;
        "sos")
                led=${LED_SOS}
                ;;
        *)
                return 1
                ;;
        esac

        echo pattern > ${LEDS_HOME}/PowerLED_${led}/trigger
        sleep 0.1
        declare -n PATTERN="PATTERN_"${code^^}
        echo "${PATTERN}" > ${LEDS_HOME}/PowerLED_${led}/pattern
        sleep 0.1
}

function cmd_ok() {
        set_led off ${LED_SOS}
        set_led ok
}

function cmd_sos() {
        set_led off ${LED_OK}
        set_led sos
}
