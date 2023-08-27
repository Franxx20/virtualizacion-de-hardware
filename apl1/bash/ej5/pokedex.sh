#!/bin/bash

#################################################################################################
#   Nombre del script: pokedex.sh
#   N° APL: 1
#   N° ejercicio: 5
#   N° Entrega: 1
#
#   Integrantes:
#       Cristian Raúl Berrios
#       Pablo Martín Ferreira
#       Franco Javier Garcete
#       Emanuel Juarez
#       Carolina Nuñez
#       Thiago Polito
#################################################################################################

readonly SUCCESS=0
readonly FAILURE=1
readonly API_URL=https://pokeapi.co/api/v2/pokemon

function check_for_jq() {
    if ! command -v jq >/dev/null; then # > /dev/null tiene que ver con "tirar" lo que imprime command. No lo entiendo
        echo "Es necesario instalar jq. Utilice los comandos:"
        echo "    sudo apt-get update"
        echo "    sudo apt-get install jq"
        exit $FAILURE
    fi
}

function usage() {
    echo "Modo de uso: ./pokedex.sh [OPCIÓN]... LISTADO"
    echo "             Donde OPCIÓN puede ser:"
    echo "              -i, --id para ingresar un listado de ids separados por comas"
    echo "              -n, --nombre para ingresar un listado de nombres separados por comas"
}

function parse_args() {
    if [[ $# = 0 ]]; then # $# es el numero de argumentos recibidos, ¿es igual a 0?
        echo "No se pasaron suficientes argumentos, utilice -h o --help para obtener ayuda"
        exit $FAILURE
    fi

    while true; do
        case "$1" in
        -i | --id)
            shift
            if [[ -z "$1" ]]; then
                echo "El listado de ids está vacío, utilice -h o --help para obtener ayuda"
                exit $FAILURE
            fi
            readarray -d ',' -t ids <<<"$1" # Lee de $1, lo separa x comas y lo guarda en ids
            shift
            ;;
        -n | --nombre)
            shift
            if [[ -z "$1" ]]; then
                echo "El listado de nombres está vacío, utilice -h o --help para obtener ayuda"
                exit $FAILURE
            fi
            readarray -d ',' -t names <<<"$1"
            shift
            ;;
        -h | --help)
            usage
            exit $SUCCESS
            ;;
        "")
            break
            ;;
        *)
            echo "Argumentos inválido, utilice -h o --help para obtener ayuda"
            exit $FAILURE
            ;;
        esac
    done
}

print_data() {
    data=$1

    id=$(jq '.id' <<<$data)
    name=$(jq '.name' <<<$data |
        tr -d '\"') # Extrae el nombre y elimina comillas
    height=$(jq '.height' <<<$data)
    weight=$(jq '.weight' <<<$data)
    types=$(jq '.types[].type.name' <<<$data |
        tr -d '\"' |
        tr '\n' ', ' |
        sed 's/,$//') # Extrae tipos elimina comillas y separa por comas

    echo ""
    echo "Id: $id"
    echo "Nombre: $name"
    echo "Altura: $height"
    echo "Peso: $weight"
    echo "Tipos: $types"
    echo ""
}

function download_data() {
    query="$1"

    response=$(curl -s -w "%{http_code}" $API_URL/{$query})
    status_code=${response: -3}
    if [[ status_code -ne 200 ]]; then
        echo "Error $status_code. Verifique los ids o nombres ingresados, o su conexión a internet"
        exit $FAILURE
    else
        data=${response:0:-3}
        print_data $data
        echo $data >"$id.$name.json"
    fi
}

function main() {
    check_for_jq
    parse_args $@
    # Si hay ids y hay nombres concatena, si solo hay nombres los pasa a guardar en ids
    if [[ -n $names ]]; then
        # Si no hay nombres simplemente no entra
        ids+=("${names[@]}")
    fi
    for i in ${!ids[@]}; do
        id=$(sed 's/\n//' <<<"${ids[$i]}")
        # Si ya se descargó el archivo solo se vuelve a leerlo, sino sí se descarga
        if [[ -n $(ls | grep -E "^$id\.|\.$id\.json") ]] >/dev/null; then
            filename=$(ls | grep -E "^$id\.|\.$id\.json")
            print_data $(<$filename)
        else
            download_data $id
        fi
    done
    return $SUCCESS
}

#################################################################################################
############ Programa ###########################################################################
#################################################################################################

main "$@"
