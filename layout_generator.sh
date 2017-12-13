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
N_SCREENS=2     # to become an option
MAX_TPW=20      

HOSTS_FILE=${ETC_HOSTS}      # to become an option
OUT_DIR=${CONFIGS_FOLDER}    # to become an option
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
echo -e "\n\n***  Getting Hosts  ***"
echo    "Host file is:   ${HOSTS_FILE}"

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

N_ALL=$(echo "${ALL_PARKS}" | wc -l)
echo "Hosts Found:   ${N_ALL}"
#----------------------------------------------------------------------------------------------------------------------
#   Recepção de hosts
#######################









############################
#   Distribuição por ecrãs
############################
#----------------------------------------------------------------------------------------------------------------------
echo -e "\n\n***  Distributing terminals  ***"

N_TPW=${N_ALL}
N_WIN=0
while [ ${N_TPW} -gt ${MAX_TPW} ]   ||   [ ${N_WIN} -lt ${N_SCREENS}  ]
do
    N_WIN=$((N_WIN+1))
    N_TPW=$((N_ALL/N_WIN))
    [ $((N_ALL%N_WIN)) -eq 0 ]  ||  N_TPW=$((N_TPW+1))
done

N_SPW=$(round_up ${N_TPW})
#----------------------------------------------------------------------------------------------------------------------
#   Distribuição por ecrãs
############################

echo ""
echo "$N_WIN windows      $N_TPW terminal/window    ${N_SPW}  terminal-spots/window"






############################
#   Fill Window Spots
############################
#----------------------------------------------------------------------------------------------------------------------
echo -e "\n\n***  Filling Windows Spots  ***"
BASE_FILE="${BIN_DIR}/generated_layouts/base"

for X in $(seq 1 1 ${N_WIN})
do
    echo -e "\nWin $X"
    WIN_FILE="${BASE_FILE}_${X}"
    cat "${BIN_DIR}/layout_templates/${N_SPW}" | sed -r 's/(child)([0-9]+)/\1'${ADD}'\2/g' | sed -r 's/(terminal)([0-9]+)/\1'${ADD}'\2/g'  >  ${WIN_FILE}

    for Y in $( seq $((N_TPW*X)) 1 $(( N_TPW*(X+1) )) )
    do
        echo "$Y"
    done
done
#----------------------------------------------------------------------------------------------------------------------
#   Fill Window Spots
############################




exit 0



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
        #BASE_N="${BASE_FILE}_${X}"
        cat "${BIN_DIR}/layout_templates/${N_BLANKS}" | sed -r 's/(child)([0-9]+)/\1'${ADD}'\2/g' | sed -r 's/(terminal)([0-9]+)/\1'${ADD}'\2/g'  >>  ${BASE_FILE}
        ADD+="_"
done

#----------------------------------------------------------------------------------------------------------------------
#   Gerador de layouts
############################












############################
#   Atribuir Comandos
############################
#----------------------------------------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------------------------------------
#   Atribuir Comandos
############################


#cp "${GROUPS_FILE}" "${GROUPS_FILE}.old_${DATE}"
#sed -i "/^ *hostgroup_name *${PK_TYPE}$/{n;{n;s/$/,${PK_NAME}/}}" "${GROUPS_FILE}"





### Alterar o titulo do terminal
# ORIG=$PS1; TITLE="\e]2;\"O que me apetecer\"\a"; PS1=${ORIG}${TITLE}
#


#  ssh -t pm@sanfrancesc "bash --rcfile ~/bashrc_custom -i"


###  PS1 do MONIT
# \[\e]0;\u@\h: \w\a\]\[\e]0; EmparkMinit - \u@\h: \w\a\][\[\e[1;34m\]\u@\H\[\e[1;33m\] -- [ emp-monit01 ] - Empark Graylog 01 Server -- \[\e[0m\] \w]\n\$

#  ssh -t pm@sanfrancesc "bash --rcfile ~/.bashrc_custom -ic"












###############################
#   Switch terminator config
################################
#
#DIRECTORY="/home/jsabino/.config/terminator"
#ORIG_FILE="config"
#SAFE_FILE="config.temp.bak"
#
#
#X=$1
#
#cp  "${DIRECTORY}"/"${ORIG_FILE}" "${DIRECTORY}"/"${SAFE_FILE}"
#
#echo "bué da cenas" > "${DIRECTORY}"/"${ORIG_FILE}"
#
#terminator -l ${X}
#
#cp "${DIRECTORY}"/"${SAFE_FILE}" "${DIRECTORY}"/"${ORIG_FILE}"
#
#rm "${DIRECTORY}"/"${SAFE_FILE}"
#



