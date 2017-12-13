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
BIN_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"

CONFIGS_FOLDER="/home/jsabino/.config/terminator/configs"
ETC_HOSTS="/etc/hosts"
NEW_FILE="config_${DATE}"
N_SCREENS=2
MAX_TPW=20

HOSTS_FILE=${ETC_HOSTS}
OUT_DIR=${CONFIGS_FOLDER}
#----------------------------------------------------------------------------------------------------------------------
#   Default Values
#######################








function round_up () {

      case $((${1})) in
          1 )  X=1 ;;
          2 )  X=2 ;;
          3 )  X=3 ;;
          4 )  X=4 ;;
          5|6 )  X=6 ;;
          7|8 )  X=8 ;;
          9 )  X=9 ;;
          10|11|12  )  X=12 ;;
          13|14|15|16 )  X=16 ;;
          17|18|19|20 )  X=20 ;;
          * ) echo "Thats a too high or unexpected value."; exit 0  ;;
      esac
      echo ${X}
}









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
COMMENT_LINE='^#'

CERCANIAS=$(cat ${HOSTS_FILE} | grep -E ${CERCA_REGEX} | grep -Ev ${COMMENT_LINE} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
SAGA=$(cat ${HOSTS_FILE} | grep -E ${SAGA_REGEX} | grep -Ev ${COMMENT_LINE} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
TOTEM=$(cat ${HOSTS_FILE} | grep -E ${TOTEM_REGEX} | grep -Ev ${COMMENT_LINE} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null
SKIDATA=$(cat ${HOSTS_FILE} | grep -E ${SKI_REGEX} | grep -Ev ${COMMENT_LINE} | sed 's/  */ /g' | cut -d' ' -f2)  || echo "" > /dev/null

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
while [ ${N_TPW} -gt ${MAX_TPW} ]   ||   [ ${N_WIN} -lt ${N_SCREENS}  ]
do
    N_WIN=$((N_WIN+1))
    #[ $((N_ALL%N_WIN)) -eq 0 ]
    N_TPW=$((N_ALL/N_WIN +1))
done
N_BLANKS=$(round_up ${N_TPW})
#----------------------------------------------------------------------------------------------------------------------
#   Distribuição por ecrãs
############################


echo "${N_ALL}"
echo "$N_WIN windows      $N_TPW terminals/window      $N_BLANKS terminal-spots/window"
#echo "$N_T1 - w1    $N_T2 - w2 "









############################
#   Gerador de layouts
############################
#----------------------------------------------------------------------------------------------------------------------
#BASE_FILE="/dev/null"
BASE_FILE="${BIN_DIR}/generated_layouts/base"
FILE_HEADER="${BIN_DIR}/layout_templates/header"

# Inicial header
cat "${FILE_HEADER}" > "${BASE_FILE}"

ADD=""
for X in $(seq 1 1 ${N_WIN})
do
cat "${BIN_DIR}/layout_templates/${N_BLANKS}" | sed -r 's/(child)([0-9]+)/\1'${ADD}'\2/g' | sed -r 's/(terminal)([0-9]+)/\1'${ADD}'\2/g'  >>  ${BASE_FILE}
    ADD+="_"
done

#----------------------------------------------------------------------------------------------------------------------
#   Gerador de layouts
############################





#cat << EOF > "${BASE_FILE}"
#    [[[child${ADD}0]]]
#      fullscreen = False
#      last_active_window = True
#      maximised = True
#      order = 0
#      parent = ""
#      position = 1920:0
#      size = 1920, 1029
#      title = 
#      type = Window
#EOF
#
#    for (( c=1; c<=${N_TPW}; c++ )) #  nr de term na janela <= q nr de term por janela
#    do
#        echo "$X  $c"
#    done








#[ $((N_ALL%2)) -eq 0 ]   &&   { N1=$((N_ALL/2)); N2=$((N1)); }  ||  { N1=$((N_ALL/2)); N2=$((N1+1)); }
#echo "${N1}  ${N2}"
















### Alterar o titulo do terminal
# ORIG=$PS1; TITLE="\e]2;\"O que me apetecer\"\a"; PS1=${ORIG}${TITLE}
#


#  ssh -t pm@sanfrancesc "bash --rcfile ~/bashrc_custom -i"





###  PS1 do MONIT
# \[\e]0;\u@\h: \w\a\]\[\e]0; EmparkMinit - \u@\h: \w\a\][\[\e[1;34m\]\u@\H\[\e[1;33m\] -- [ emp-monit01 ] - Empark Graylog 01 Server -- \[\e[0m\] \w]\n\$

#  ssh -t pm@sanfrancesc "bash --rcfile ~/.bashrc_custom -ic"








