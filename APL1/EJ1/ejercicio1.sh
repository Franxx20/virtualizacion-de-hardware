#!/bin/bash

#ejercicio1.sh - APL1 - Ejercicio 1 - ENTREGA
#Ezequiel Sebastian Catania - 43.323.210
#Augusto Martin Coronati - 43.572.601
#Agustin Marcelo Marco - 41.572.925
#Mariano Lionel Rodriguez - 39.336.952
#Ignacio Romero - 44.209.416

ErrorS()
{
	echo "Error. La sintaxis del script es la siguiente:"
	echo "Opcion si quiero obtener la cantidad de lineas del archivo: $0 nombre_archivo L"
	echo "Opcion si quiero obtener la cantidad de caracteres del archivo: $0 nombre_archivo C"
	echo "Opcion si quiero obtener la longitud de linea maxima: $0 nombre_archivo M"
}

ErrorP()
{
	echo "Error. nombre_archivo no existe o no tiene permiso de lectura."
}

if test $# -lt 2; then
	ErrorS
fi
if ! test -r $1 ; then
	ErrorP
elif test -f $1 && (test $2 = "L" || test $2 = "C" ||  test $2 = "M"); then
	if test $2 = "L"; then
		res=`wc -l $1`
		echo "Cantidad de lineas del archivo: $res"
	elif test $2 = "C"; then
		res=`wc -m $1`
		echo "Cantidad de caracteres del archivo: $res"
	elif test $2 = "M"; then
		res=`wc -L $1`
		echo "Longitud de linea maxima: $res"
	fi
else
	ErrorS
fi

#RESPUESTAS:
#1) El objetivo de este script es mostrar la cantidad de lineas, cantidad de caracteres o la longitud de linea mas larga del archivo recibido como parametro junto a un caracter que indica cual de las 3 opciones anteriores debe informar.

#2) Recibe 2 parametros: el archivo a leer y un caracter que representa que informacion quiero obtener, el cual puede ser una L, C o M.

#3) Primero el codigo verifica si la cantidad de parametros recibidos es menor que 2 y en ese caso muestra por pantalla un error de sintaxis indicando las 3 formas posibles de sintaxis correctas. Luego comprueba si el archivo recibido no existe o si no tiene permisos de lectura, informando el error por pantalla. Continua comprobando si el primer parametro existe y es un archivo regular y si el segundo parametro es una L, C o M para luego calcular y mostrar la cantidad de lineas, cantidad de caracteres o la longitud de la linea maxima respectivamente. En caso que la condicion no se cumpla, informa el error de sintaxis.

#5) La variable "$#" brinda la cantidad de parametros pasados al script. "$0" contiene el nombre del script, "$n" (siendo n un numero natural) almacena un parametro de entrada, "$@" brinda una lista de todos los parametros pasados al script, "$*" brinda una cadena con todos los parametros pasados al script, "$?" brinda el resultado del ultimo comando ejecutado, "$$" el PID de la shell actual o proceso ejecutado y "$!" el PID del ultimo comando ejecutado en segundo plano.

#6) Comillas simples verticales ('): Se utilizan para cadenas (texto fuerte). El Shell no realiza reemplazos de variables. 
#Comillas dobles ("): Se utilizan para cadenas (texto debil), el Shell realiza reemplazos de variables. 
#Comillas francesas/ Acento grave (`): Se utilizan para obtener el resultado de la ejecucion de un comando. EL Shell primero realiza reemplazos de variables y luego ejecuta el comando.


#FIN DE ARCHIVO