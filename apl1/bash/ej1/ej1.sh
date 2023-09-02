#!/bin/bash
#################################################################################################
#   Nombre del script: ej1.sh
#   N° APL: 1
#   N° ejercicio: 1
#   N° Entrega: 1
#
#   Integrantes:
#       Cristian Raúl Berrios
#       Pablo Martín Ferreira
#       Franco Javier Garcete
#       Carolina Nuñez
#       Thiago Polito
#################################################################################################
ayuda () {
    echo -e "este script toma un archivo CSV con los datos de estacion petrolera, y devuelve un archivo de salida con los datos del archivo procesados"

    echo "la sintaxis es la siguiente:"
    echo "[-e / --entrada] Ruta del archivo de entrada (incluye el nombre del archivo)"
    echo "[-a / --archivo] Si esta presente, indica que la salida va a ser por archivo. Opcional"
    echo "[-e / --entrada] Ruta del archivo de salida (incluye el nombre del archivo). Solo puede estar presente si se usa el parametro -a / --archivo"
}

# parsear_cvs () {
#     columna_hora=( $(tail -n +2 "$ruta_archivo_entrada" | cut -d ',' -f1) )
#
#     for hora in "${columna_hora[@]}"
#     do
#         if ! [[ -n "$hora" ]] && ! [[ "$(date -d "$hora" +%H:%M 2> /dev/null)" = "$hora" ]]; then
#             echo 'hora invalida'
#         fi
#     done
#
#     columna_motor1=( $(tail -n +2 "$ruta_archivo_entrada" | cut -d ',' -f2) )
#     columna_motor2=( $(tail -n +2 "$ruta_archivo_entrada" | cut -d ',' -f3) )
#     columna_temperatura=( $(tail -n +2 "$ruta_archivo_entrada" | cut -d ',' -f4) )
# }

parsear_cvs2 (){
    while IFS="," read -r r1 r2 r3 r4
    do
        columna_hora+=("$r1")
        columna_motor1+=("$r2")
        columna_motor2+=("$r3")
        columna_temperatura+=("$r4")
    done < <(tail -n +2 "$ruta_archivo_entrada")

}


calculos () {

    # valida las fechas
    # parsear hora y verificar
    for registro in "${columna_hora[@]}"
    do
        # if  [[ -z "$hora" ]] && ! [[ "$(date -d "$hora" +%H:%M 2> /dev/null)" = "$hora" ]]; then
        #     echo 'hora invalida'
        #     exit 8
        # fi
        hora=$(echo "$registro" | cut -f1 -d:)
        # le saca el cero de adelante para que pueda ser leido como un numero decimal y no un octal
        hora=${hora#0}
        minuto=$(echo "$registro" | cut -f2 -d:)
        # le saca el cero de adelante para que pueda ser leido como un numero decimal y no un octal
        minuto=${minuto#0}
        # checkea hora valida
        # echo "hora ahora $hora"
        if ! [[ "$hora" =~ ^[0-9]+$ ]]
        then
            echo "hora invalida"
            exit 10
        elif   [[ $hora -lt 0 ]] || [[ $hora -gt 23 ]]
        then
            echo "rango de hora invalida"
            exit 12
        fi

        # checkea minuto valido
        # echo "minuto ahora $minuto"
        if ! [[ "$minuto" =~ ^[0-9]+$ ]] #&&
        then
            echo "minuto invalido"
            exit 11
        elif   [[ $minuto -lt 0 ]] ||  [[ $minuto -gt 59 ]]
        then
            echo "rango de minuto invalido"
            exit 12
        fi
    done

    #calcula el maximo del motor 1
    motor1MasCaliente=${columna_motor1[0]}
    for temperatura in "${columna_motor1[@]}"
    do
        if [[ "$temperatura" -le 100 && "$temperatura" -ge 0 ]]
        then
            if [[ "$temperatura" -ge "$motor1MasCaliente" ]]
            then
                motor1MasCaliente="$temperatura"
            fi
        else
            echo "rango de temperatura invalido motor 1[0 ... 100] temp $temperatura"
            exit 6
        fi
    done

    #calcula el maximo del motor 2
    motor2MasCaliente=${columna_motor2[0]}
    for temperatura2 in "${columna_motor2[@]}"
    do
        if [[ "$temperatura2" -le 100 && "$temperatura2" -ge 0 ]]
        then
            if [[ "$temperatura2" -ge "$motor2MasCaliente" ]]
            then
                motor2MasCaliente="$temperatura2"
            fi
        else
            echo "rango de temperatura2 invalido motor 2[0 ... 100] temp $temperatura2"
            exit 6
        fi
    done

    # calcula el promedio
    sumaTemperaturas=0
    cantRegistros=0
    for k in "${columna_temperatura[@]}"
    do
        ((sumaTemperaturas += k))
        ((cantRegistros += 1))
    done


    # temperaturaPromedio=$(echo "scale=2; $sumaTemperaturas / $cantRegistros" | bc -l)
    # result=$(awk "BEGIN { printf(\"%.2f\", $num1 * $num2) }")
    temperaturaPromedio=$(awk "BEGIN { printf(\"%.2f\", $sumaTemperaturas /$cantRegistros)}")

}
#
#
# echo "suma $sumaTemperaturas"
# echo "suma $cantRegistros"
#
mostrar_en_pantalla(){
    calculos
    echo "Uso máximo motor 1: $motor1MasCaliente"
    echo "Uso máximo motor 2: $motor2MasCaliente"
    echo "promedio de temperatura: $temperaturaPromedio"
}

enviar_a_archivo(){
    calculos
    { echo "Motor1=$motor1MasCaliente"; echo "Motor2=$motor2MasCaliente"; echo "Temperatura=$temperaturaPromedio"; } >> "$ruta_archivo_salida"
}
#
#
#
checkopt () {
    SHORT=:e:,a,s:,h
    LONG=:entrada:,archivo,salida:,help
    ARGUMENTOS_VALIDOS=$(getopt -a -n ej1 --options $SHORT --longoptions $LONG -- "$@" )

    if [[ $? -ne 0 ]]
    then
        echo "[Error] - Operacion Desconocida"
        echo "Intenta $0 --help/-h para descubrir como funciona el programa"
        exit 1
    fi

    if [[ "$#" -lt 2 ]]
    then
        echo "Error, parametros insuficientes"
        exit 5
    fi

    if [[ "$#" -gt 5 ]]
    then
        echo "Error, demasiados parametros"
        exit 6
    fi


    tiene_archivo_salida=false
    tiene_archivo_entrada=false
    muestra_en_pantalla=false


    eval set -- "$ARGUMENTOS_VALIDOS"
    while true
    do
        case "$1" in
            -e | --entrada)
                muestra_en_pantalla=true
                if [[ $2 == *.csv ]]
                then
                    ruta_archivo_entrada=$2
                else
                    echo "extension de archivo de entrada incorrecto"
                    exit 2
                fi

                # parsear_cvs "$ruta_archivo_entrada"
                shift 2
                ;;

            -a | --archivo)
                tiene_archivo_entrada=true
                shift 1
                ;;

            -s | --salida)
                tiene_archivo_salida=true
                ruta_archivo_salida="$2"
                # enviar_a_archivo "$ruta_archivo_salida"
                shift 2
                ;;

            -h | --help)
                ayuda
                exit 0
                ;;

            --)
                shift
                break
                ;;

            *)
                echo "Error! parametro no valido"
                exit 1
                ;;
        esac
    done


    if [[ -f "$ruta_archivo_entrada" ]]
    then
        parsear_cvs2 "$ruta_archivo_entrada"
    else
        echo "archivo de entrada no valido"
        exit 2
    fi

    if [[ $tiene_archivo_salida == true ]]
    then
        # if [[ -f "$ruta_archivo_salida" ]]; then
        enviar_a_archivo "$ruta_archivo_salida"
        muestra_en_pantalla=false
        # else
        # echo "archivo de salida mal espeficicado"
        # exit 4
        # fi
    fi



}
main () {

    checkopt "$@"


    if  [[ $tiene_archivo_entrada == true ]]
    then

        if [[ $tiene_archivo_salida == false ]]
        then
            echo "No ingreso una ruta para el archivo de salida"
            exit 1
        fi
    fi

    if [[ $tiene_archivo_salida == true ]]
    then

        if [[ $tiene_archivo_entrada == false ]]
        then
            echo "No ingreso una ruta para el archivo de entrada"
            exit 1
        fi

    fi

    if [[ $muestra_en_pantalla == true ]]
    then
        mostrar_en_pantalla
        exit 0
    fi
}


main "$@"
