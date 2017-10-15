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
#   Recepção de hosts
#######################
#----------------------------------------------------------------------------------------------------------------------
echo -e "Host file is:\t${HOSTS_FILE}"

CERCA_REGEX=' cerca$'
SAGA_REGEX=' saga$'
TOTEM_REGEX=' totem$'
SKI_REGEX=' skidata$'

CERCANIAS=$(cat ${HOSTS_FILE} | grep -E ${CERCA_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
SAGA=$(cat ${HOSTS_FILE} | grep -E ${SAGA_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
TOTEM=$(cat ${HOSTS_FILE} | grep -E ${TOTEM_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
SKIDATA=$(cat ${HOSTS_FILE} | grep -E ${SKI_REGEX} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null

ALL_PARKS=$(echo -e "${CERCANIAS}\n${SAGA}\n${TOTEM}\n${SKIDATA}" ) # | sed '/^\s*$/d')
#----------------------------------------------------------------------------------------------------------------------
#   Recepção de hosts
#######################





############################
#   Distribuição por ecrãs
############################
#----------------------------------------------------------------------------------------------------------------------
N_ALL=$(echo "${ALL_PARKS}" | wc -l)
N_TPW=${N_ALL}

N_WIN=1
while [ ${N_TPW} -gt 20 ]
do
    N_WIN=$((N_WIN+1))
    #[ $((N_ALL%N_WIN)) -eq 0 ]
    N_TPW=$((N_ALL/N_WIN +1))
done

if [ ${N_WIN} == 1 ] && [[ ${N_TPW} -gt 4 ]]
then
    N_WIN="${N_SCREENS}"
    { [ $((N_ALL%2)) -eq 0 ]   &&   { N_T1=$((N_ALL/2)); N_T2=$((N_T1)); } }  ||  { N_T2=$((N_ALL/2)); N_T1=$((N_T2+1)); } 
fi

#----------------------------------------------------------------------------------------------------------------------
#   Distribuição por ecrãs
############################






############################
#   Gerador de layouts
############################
#----------------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------------


echo "${N_ALL}"

echo "$N_WIN windows    $N_TPW terminals/window"

echo "$N_T1 - w1    $N_T2 - w2 "



#[ $((N_ALL%2)) -eq 0 ]   &&   { N1=$((N_ALL/2)); N2=$((N1)); }  ||  { N1=$((N_ALL/2)); N2=$((N1+1)); }
#echo "${N1}  ${N2}"






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


#  ssh -t pm@sanfrancesc "bash --rcfile ~/bashrc_custom -i"












