#!/bin/bash
# Ejercicio 1
# Objetivos de aprendizaje: manejo de archivos CSV, manejo de parámetros y salida por pantalla.
# En una estación de extracción petrolera de la Patagonia Argentina, un dispositivo mantiene un
# registro de la cantidad de petróleo extraído por hora, junto con otros parámetros como la
# temperatura de los motores. Como este dispositivo se encuentra en una zona sin cobertura de red
# celular, los datos se almacenan en formato CSV que luego se transmiten al servidor utilizando una
# conexión satelital. Al llegar al servidor, se analizan para luego guardar los datos relevantes en una
# base de datos.
# Crear dos scripts, uno en bash y otro en Powershell, que analicen los datos recibidos en el archivo
# con formato CSV y calculen el porcentaje máximo de uso de cada uno de los motores y el promedio
# de temperatura. La salida generada por los scripts debe mostrarse por pantalla o guardarse en un
# archivo, dependiendo de los parámetros pasados.
# Formato del archivo de entrada:
# Horario, UsoMotor1, UsoMotor2, Temperatura
# 09:34, 12, 89, 20
# 10:34, 44, 32, 21
# 15:00, 100, 10, 35
# Donde:
# • Horario: HH:mm
# • UsoMotor1: porcentaje de uso del motor 1. Valor entre 0 y 100, solo números enteros.
# • UsoMotor2: porcentaje de uso del motor 2. Valor entre 0 y 100, solo números enteros.
# • Temperatura: temperatura ambiente en grados celsius.
# Formato de la salida por pantalla:
# Uso máximo motor 1: 100
# Uso máximo motor 2: 89
# Promedio de temperatura: 25,33
# Formato de la salida por archivo:
# Motor1=100
# Motor2=89
# Temperatura=25,33
#
#



parsear_cvs () {
    columna_hora=( $(tail -n +2 $ruta_archivo | cut -d ',' -f1) )
    columna_motor1=( $(tail -n +2 $ruta_archivo | cut -d ',' -f2) )
    columna_motor2=( $(tail -n +2 $ruta_archivo | cut -d ',' -f3) )
    columna_temperatura=( $(tail -n +2 $ruta_archivo | cut -d ',' -f4) )
    # echo "array of horas  : ${columna_hora[@]}"
    # echo "array of motor1 : ${columna_motor1[@]}"
    # echo "array of motor2 : ${columna_motor2[@]}"
    # echo "array of temperatura : ${columna_temperatura[@]}"
}

#
#

calculos () {
    motor1MasCaliente=${columna_motor1[0]}
    for porcentaje in "${columna_motor1[@]}"
    do
        if [[ "$porcentaje" -gt "$motor1MasCaliente" && "$porcentaje" -lt 101 && "$porcentaje" -gt -1 ]]
        then
            motor1MasCaliente="$porcentaje"
        fi
    done
    
    echo  "motor mas caliente: $motor1MasCaliente"
    #
    motor2MasCaliente=${columna_motor2[0]}
    for porcentaje in "${columna_motor2[@]}"
    do
        if [[ "$porcentaje" -gt "$motor2MasCaliente" && "$porcentaje" -lt 101 && "$porcentaje" -gt -1 ]]
        then
            motor2MasCaliente="$porcentaje"
        fi
    done
    
    echo  "motor mas caliente: $motor2MasCaliente"
    
    sumaTemperaturas=0
    cantRegistros=0
    for k in "${columna_temperatura[@]}"
    do
        let sumaTemperaturas+=$k
        let cantRegistros+=1;
    done
    
    
    temperaturaPromedio=$(echo "scale=2; $sumaTemperaturas / $cantRegistros" | bc -l)
    
}
#
#
# echo "suma $sumaTemperaturas"
# echo "suma $cantRegistros"
#
mostrar_en_pantalla(){ calculos
    echo "Uso máximo motor 1: $motor1MasCaliente"
    echo "Uso máximo motor 2: $motor2MasCaliente"
    echo "promedio de temperatura: $temperaturaPromedio"
}

enviar_a_archivo(){
    calculos
    echo "Motor1=$motor1MasCaliente" >> $nombreArchivoSalida
    echo "Motor2=$motor2MasCaliente" >> $nombreArchivoSalida
    echo "Temperatura=$temperaturaPromedio" >> $nombreArchivoSalida
}
#
#
SHORT=:e:,a,s:,h,?
LONG=:entrada:,archivo,salida:,help
ARGUMENTOS_VALIDOS=$(getopt -a -n ej1 --options $SHORT --longoptions $LONG -- "$@")


if [[ $? -ne 0 ]]; then
    echo "[Error] - Operacion Desconocida"
    echo "Intenta $0 --help/-h/-? para descubrir como funciona el programa"
    exit 1
fi

eval set -- "$ARGUMENTOS_VALIDOS"

tiene_archivo_salida=false
tiene_archivo_entrada=false
muestra_en_pantalla=false


while :
do
    case "$1" in
        -e | --entrada)
            muestra_en_pantalla=true
            ruta_archivo=$2
            parsear_cvs "$ruta_archivo"
        shift 2;;
        
        -a | --archivo)
            tiene_archivo_entrada=true
        shift 1;;
        
        -s | --salida)
            tiene_archivo_salida=true
            nombreArchivoSalida="$2"
            enviar_a_archivo "$nombreArchivoSalida"
        shift 2;;
        
        --)
        shift; break;;
        
    esac
done

if [[ $muestra_en_pantalla == true ]]
then
    mostrar_en_pantalla
fi

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



