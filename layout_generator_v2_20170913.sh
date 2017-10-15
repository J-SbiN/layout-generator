#!/bin/bash
set -eo pipefail



function show_help {
    echo -e "\n\t\t usage: <layout_generator.sh> <-H /path/to/hosts/file> [-v]\n"
    exit 0
}

function set_debug {
    set -x
}



if [ $# -eq 0 ]; then
    echo "This script requires arguments..."
    show_help
    exit 1
fi




#######################
#   Default Values
#######################
#----------------------------------------------------------------------------------------------------------------------
DATE=$(date +%Y%m%d_%H%M%S)

CONFIGS_FOLDER="/home/jsabino/.config/terminator/configs"
ETC_HOSTS="/etc/hosts"
NEW_FILE="config_${DATE}"
N_SCREENS=2;
MAX_TPW=10;

HOSTS_FILE=${ETC_HOSTS}
OUT_DIR=${CONFIGS_FOLDER}
#----------------------------------------------------------------------------------------------------------------------
#   Default Values
#######################





################
#   MENU
################
#----------------------------------------------------------------------------------------------------------------------
while :
do
    case $1 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -v|--verbose|--debug)
            set_debug
            ;;
        -H|--hosts-file)
            if [ -n "$2" ]; then
                HOSTS_FILE=$2
                shift
            else
                echo -e "ERROR: '${1}' requires a non-empty option argument.\n"
                exit 1
            fi
            ;;
        --hosts-file=?*)
            HOSTS_FILE=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        -o|--out-dir)
            if [ -n "$2" ]; then
                OUT_DIR=$2
                shift
            else
                printf 'ERROR: "--out-dir" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --out-dir=?*)
            OUT_DIR=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --hosts-file=|--out-dir=)
            echo "ERROR: '${1}' requires a non-empty option argument.\n"
            exit 1
            ;;
        --)   # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac
    shift
done
#----------------------------------------------------------------------------------------------------------------------
#   MENU
################








#######################
#   Hosts Reception
#######################
#----------------------------------------------------------------------------------------------------------------------
echo -e "Host file is:\t${HOSTS_FILE}"

ALL_REGEX='( cerca$| saga$| totem$| skidata$)'
ALL_PARKS=$(cat ${HOSTS_FILE} | grep -E "${ALL_REGEX}" | sed 's/  */ /g' | cut -d' ' -f2)  || { echo "No Hosts Selected"; exit 0; }


##############
##    --> find a way to select the parks to connect to
##    --> display parks in windows per type?
##############
CERCA_REGEX=' cerca$'
SAGA_REGEX=' saga$'
TOTEM_REGEX=' totem$'
SKIDATA_REGEX=' skidata$'

CERCANIAS=$(cat ${HOSTS_FILE} | grep -E ${CERCA_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
SAGA=$(cat ${HOSTS_FILE} | grep -E ${SAGA_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
TOTEM=$(cat ${HOSTS_FILE} | grep -E ${TOTEM_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
SKIDATA=$(cat ${HOSTS_FILE} | grep -E ${SKIDATA_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null

### Just Checking
# echo "${ALL_PARKS}"
# echo "${CERCANIAS}"
# echo "${SAGA}"
# echo "${TOTEM}"
# echo "${SKIDATA}"

#----------------------------------------------------------------------------------------------------------------------
#   Hosts Reception
#######################





########################
#   Sorting Windows
########################
#----------------------------------------------------------------------------------------------------------------------
N_ALL=$(echo "${ALL_PARKS}" | sed '/^\s*$/d' |wc -l)
N_TPW=${N_ALL}

N_WIN=1
while [[ ${N_TPW} -gt ${MAX_TPW} ]] || [[ ${N_WIN} -lt ${N_SCREENS} ]]
do
    N_WIN=$((N_WIN+1))
    N_TPW=$((N_ALL/N_WIN))
done

REM=$((N_ALL%N_WIN))
{ [ ${REM} -eq 0 ]  &&  N_TPW=$((N_ALL/N_WIN)); }  ||  REMAINDER=${REM};

N_TWX=()
for X in $(seq 1 1 ${N_WIN})
do   # está com o problema de encher mais que 20 terminais por janela
    if [[ ${X} -le ${REM} ]]
    then
        N_TPW1=$((N_TPW+1))
        N_TWX+=("${N_TPW1}")
    else
        N_TWX+=("${N_TPW}")
    fi
done

## Just Checking
echo "${N_ALL} parks at all."
echo "${N_WIN} windows     ${N_TPW} terminals/window      Remainder = ${REMAINDER}"
echo "${N_TWX[*]}"

##############
##    --> display parks in windows per type?
##############

#----------------------------------------------------------------------------------------------------------------------
#   Sorting Windows
########################




###########################
#   Generating Layouts
###########################
#----------------------------------------------------------------------------------------------------------------------

#for $(seq 1 1 ${N_WIN})
#do
    
#done

#----------------------------------------------------------------------------------------------------------------------
#   Generating Layouts
###########################

#    while nr de term na janela <= q nr de term por janela
#    do

#    done




#sed -r "0,/^(    \[\[\[terminal_*[0-9]+\]\]\])$/s//\1\n      command = ssh ${PK_USER}@${HOST}/"

#  cat /home/jsabino/pasta/terminator/layout_generator/layout_templates/4 | sed -r "/^(    \[\[\[terminal_*[0-9]+\]\]\])$/s//\1\n      command = ssh ${PK_USER}@${HOST}\n      group = cenas/"





########################
#   Starting Layout
########################
#----------------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------------
#   Starting Layout
########################






#cat << EOF > "${CONFIGS_FOLDER}"/"${NEW_FILE}"
#[global_config]
#  suppress_multiple_term_dialog = True
#[keybindings]
#[layouts]
#  [[default]]
#    [[[child1]]]
#      parent = window0
#      type = Terminal
#    [[[window0]]]
#      parent = ""
#      type = Window
#[plugins]
#[profiles]
#  [[default]]
#    background_darkness = 0.9
#    background_image = None
#    background_type = transparent
#    scrollback_infinite = True
#  [[park]]
#    background_image = None
#    scrollback_infinite = True
#EOF









### Alterar o titulo do terminal
# ORIG=$PS1; TITLE="\e]2;\"O que me apetecer\"\a"; PS1=${ORIG}${TITLE}
#

###  PS1 do MONIT
# \[\e]0;\u@\h: \w\a\]\[\e]0; EmparkMinit - \u@\h: \w\a\][\[\e[1;34m\]\u@\H\[\e[1;33m\] -- [ emp-monit01 ] - Empark Graylog 01 Server -- \[\e[0m\] \w]\n\$

#  ssh -t pm@sanfrancesc "bash --rcfile ~/bashrc_custom -i"












